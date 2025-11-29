-- QUICK FIX: Run this single script to fix test5 milestones
-- This combines diagnosis, fix, and backfill in one script

-- ============================================
-- PART 0: FIX THE TRIGGER FUNCTION FIRST
-- ============================================
-- The sync_trainer_total_points() function has a bug where it tries to
-- reference NEW.trainer_id even when triggered from trainers table

DROP FUNCTION IF EXISTS sync_trainer_total_points() CASCADE;

CREATE OR REPLACE FUNCTION sync_trainer_total_points()
RETURNS TRIGGER AS $$
DECLARE
    v_trainer_id UUID;
BEGIN
    -- Determine the trainer_id based on which table triggered this
    IF TG_TABLE_NAME = 'pokemon_inventory' THEN
        v_trainer_id := COALESCE(NEW.trainer_id, OLD.trainer_id);
    ELSIF TG_TABLE_NAME = 'trainers' THEN
        v_trainer_id := COALESCE(NEW.id, OLD.id);
    ELSIF TG_TABLE_NAME = 'user_achievements' THEN
        v_trainer_id := COALESCE(NEW.trainer_id, OLD.trainer_id);
    ELSE
        v_trainer_id := COALESCE(NEW.trainer_id, OLD.trainer_id, NEW.id, OLD.id);
    END IF;
    
    -- Recalculate total_points for the affected trainer
    UPDATE trainers
    SET total_points = (
        COALESCE((
            SELECT SUM(points)
            FROM pokemon_inventory
            WHERE trainer_id = trainers.id
        ), 0) + COALESCE(achievement_points, 0)
    )
    WHERE id = v_trainer_id;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Recreate triggers
DROP TRIGGER IF EXISTS trigger_sync_total_points_on_pokemon ON pokemon_inventory;
CREATE TRIGGER trigger_sync_total_points_on_pokemon
AFTER INSERT OR UPDATE OR DELETE ON pokemon_inventory
FOR EACH ROW
EXECUTE FUNCTION sync_trainer_total_points();

DROP TRIGGER IF EXISTS trigger_sync_total_points_on_achievement_points ON trainers;
CREATE TRIGGER trigger_sync_total_points_on_achievement_points
AFTER UPDATE OF achievement_points ON trainers
FOR EACH ROW
WHEN (OLD.achievement_points IS DISTINCT FROM NEW.achievement_points)
EXECUTE FUNCTION sync_trainer_total_points();

-- ============================================
-- PART 1: FIX THE get_user_achievements FUNCTION
-- ============================================

DROP FUNCTION IF EXISTS get_user_achievements(UUID);

CREATE OR REPLACE FUNCTION get_user_achievements(p_user_id UUID)
RETURNS TABLE (
    achievement_id UUID,
    achievement_key TEXT,
    title TEXT,
    description TEXT,
    category TEXT,
    icon TEXT,
    unlocked_at TIMESTAMP WITH TIME ZONE,
    points INTEGER
) AS $$
BEGIN
    -- Handle BOTH auth.users.id AND test_username.id
    -- Strategy:
    -- 1. Direct match with user_achievements.user_id
    -- 2. Match via trainers.test_user_id (for test_username users)  
    -- 3. Match via trainers.user_id (for auth.users)
    
    RETURN QUERY
    SELECT 
        a.id,
        a.achievement_key,
        a.title,
        a.description,
        a.category,
        a.icon,
        ua.unlocked_at,
        a.points
    FROM user_achievements ua
    JOIN achievements a ON ua.achievement_id = a.id
    WHERE ua.user_id = p_user_id
       OR ua.trainer_id IN (
           SELECT id FROM trainers 
           WHERE test_user_id = p_user_id 
              OR user_id::text::uuid = p_user_id
       )
    ORDER BY ua.unlocked_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PART 2: BACKFILL ACHIEVEMENTS FOR TEST5
-- ============================================

DO $$
DECLARE
    v_test_user_id UUID;
    v_trainer_id UUID;
    v_user_id UUID;
    v_result RECORD;
    v_achievement_count INT := 0;
BEGIN
    RAISE NOTICE '======================================';
    RAISE NOTICE 'FIXING TEST5 MILESTONES';
    RAISE NOTICE '======================================';
    
    -- Get test5's IDs
    SELECT tu.id, t.id, us.user_id 
    INTO v_test_user_id, v_trainer_id, v_user_id
    FROM test_username tu
    LEFT JOIN trainers t ON t.test_user_id = tu.id OR t.name = 'test5'
    LEFT JOIN user_stats us ON us.trainer_id = t.id
    WHERE tu.username = 'test5'
    LIMIT 1;
    
    IF v_test_user_id IS NULL THEN
        RAISE NOTICE '❌ ERROR: test5 not found in test_username table';
        RETURN;
    END IF;
    
    IF v_trainer_id IS NULL THEN
        RAISE NOTICE '❌ ERROR: test5 trainer not found';
        RAISE NOTICE '   You need to create a trainer for test5 first';
        RETURN;
    END IF;
    
    RAISE NOTICE '✅ Found test5:';
    RAISE NOTICE '   - test_username.id: %', v_test_user_id;
    RAISE NOTICE '   - trainer.id: %', v_trainer_id;
    RAISE NOTICE '   - user_stats.user_id: %', COALESCE(v_user_id::text, 'NULL');
    RAISE NOTICE '';
    
    -- If user_id is NULL, we need to use test_user_id for user_stats
    IF v_user_id IS NULL THEN
        RAISE NOTICE '⚠️  WARNING: user_stats.user_id is NULL';
        RAISE NOTICE '   Trying to use test_username.id instead...';
        v_user_id := v_test_user_id;
    END IF;
    
    -- Check current stats
    DECLARE
        v_total_captures INT;
        v_current_streak INT;
    BEGIN
        SELECT total_captures, current_login_streak
        INTO v_total_captures, v_current_streak
        FROM user_stats
        WHERE user_id = v_user_id OR trainer_id = v_trainer_id
        LIMIT 1;
        
        RAISE NOTICE '📊 test5 Stats:';
        RAISE NOTICE '   - Total captures: %', COALESCE(v_total_captures, 0);
        RAISE NOTICE '   - Login streak: %', COALESCE(v_current_streak, 0);
        RAISE NOTICE '';
        
        IF COALESCE(v_total_captures, 0) = 0 THEN
            RAISE NOTICE '⚠️  test5 has no captures - no achievements to award';
            RAISE NOTICE '   Have them capture a Pokemon first!';
            RETURN;
        END IF;
    END;
    
    -- Award achievements
    RAISE NOTICE '🔄 Checking for achievements to award...';
    RAISE NOTICE '';
    
    FOR v_result IN 
        SELECT * FROM check_and_award_achievements(v_user_id, v_trainer_id)
    LOOP
        v_achievement_count := v_achievement_count + 1;
        RAISE NOTICE '🎉 UNLOCKED: % (% points)', 
            v_result.title,
            v_result.points;
        RAISE NOTICE '   %', v_result.description;
        RAISE NOTICE '';
    END LOOP;
    
    IF v_achievement_count = 0 THEN
        RAISE NOTICE '✅ No new achievements to award - test5 already has all eligible achievements';
    ELSE
        RAISE NOTICE '✅ Awarded % new achievement(s) to test5!', v_achievement_count;
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '======================================';
    RAISE NOTICE 'SUMMARY';
    RAISE NOTICE '======================================';
    
    -- Show final achievement count
    DECLARE
        v_total_achievements INT;
        v_total_points INT;
    BEGIN
        SELECT COUNT(*), COALESCE(SUM(a.points), 0)
        INTO v_total_achievements, v_total_points
        FROM user_achievements ua
        JOIN achievements a ON a.id = ua.achievement_id
        WHERE ua.trainer_id = v_trainer_id;
        
        RAISE NOTICE 'test5 now has:';
        RAISE NOTICE '   - % total achievements', v_total_achievements;
        RAISE NOTICE '   - % achievement points', v_total_points;
    END;
    
    RAISE NOTICE '';
    RAISE NOTICE '✅ Fix complete! Test the Milestones button in the app.';
    RAISE NOTICE '======================================';
END $$;

-- ============================================
-- PART 3: VERIFY THE FIX
-- ============================================

-- Test the function with test5's ID
SELECT 
    '=== Testing get_user_achievements() ===' as test,
    COUNT(*) as achievements_returned
FROM test_username tu
CROSS JOIN LATERAL get_user_achievements(tu.id) gua
WHERE tu.username = 'test5';

-- Show test5's achievements
SELECT 
    '=== test5 Achievements ===' as result,
    gua.title,
    gua.category,
    gua.points,
    gua.unlocked_at
FROM test_username tu
CROSS JOIN LATERAL get_user_achievements(tu.id) gua
WHERE tu.username = 'test5'
ORDER BY gua.unlocked_at DESC;

-- Final message
SELECT '✅ Script complete! Refresh the app and check test5''s Milestones.' as status;
