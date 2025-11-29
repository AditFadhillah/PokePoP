-- Fix for test5 milestones not showing
-- The problem: MilestonesModal passes test_username.id but user_achievements uses auth.users.id OR test_user_id
-- Solution: Create an alternative function that works with test_username.id

-- Step 1: Create a new function that accepts test_username.id
CREATE OR REPLACE FUNCTION get_user_achievements_by_test_user(p_test_user_id UUID)
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
    -- First try to find achievements using trainer's test_user_id
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
    JOIN trainers t ON ua.trainer_id = t.id
    WHERE t.test_user_id = p_test_user_id
    ORDER BY ua.unlocked_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Update the original get_user_achievements to handle BOTH auth.users.id AND test_username.id
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
    -- Try multiple strategies to find user achievements:
    -- 1. Direct match with user_id in user_achievements
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
              OR user_id = p_user_id::text::uuid
       )
    ORDER BY ua.unlocked_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Verify test5's data structure
SELECT 
    '=== Verification for test5 ===' as step,
    tu.id as test_username_id,
    tu.username,
    t.id as trainer_id,
    t.name as trainer_name,
    t.test_user_id,
    CASE 
        WHEN t.test_user_id = tu.id THEN '✓ Linked via test_user_id'
        ELSE '✗ NOT linked via test_user_id'
    END as link_status
FROM test_username tu
LEFT JOIN trainers t ON t.test_user_id = tu.id
WHERE tu.username = 'test5';

-- Step 4: Test the new function with test5
SELECT 
    '=== Testing get_user_achievements with test5 ===' as step,
    gua.*
FROM test_username tu
CROSS JOIN LATERAL get_user_achievements(tu.id) gua
WHERE tu.username = 'test5';

-- Step 5: If no achievements found, check if test5 has stats that qualify for achievements
SELECT 
    '=== Check if test5 qualifies for achievements ===' as step,
    tu.username,
    us.total_captures,
    us.current_login_streak,
    us.total_duration_minutes,
    CASE 
        WHEN us.total_captures >= 1 THEN '✓ Qualifies for first_capture'
        ELSE '✗ No captures yet'
    END as first_capture_status,
    CASE 
        WHEN us.total_captures >= 5 THEN '✓ Qualifies for capture_5'
        ELSE '✗ Needs ' || (5 - us.total_captures) || ' more captures'
    END as capture_5_status
FROM test_username tu
JOIN trainers t ON t.test_user_id = tu.id
JOIN user_stats us ON us.trainer_id = t.id
WHERE tu.username = 'test5';

-- Step 6: Backfill achievements for test5 if needed
DO $$
DECLARE
    v_test_user_id UUID;
    v_trainer_id UUID;
    v_user_id UUID;
    v_result RECORD;
BEGIN
    -- Get test5's IDs
    SELECT tu.id, t.id, us.user_id INTO v_test_user_id, v_trainer_id, v_user_id
    FROM test_username tu
    JOIN trainers t ON t.test_user_id = tu.id
    LEFT JOIN user_stats us ON us.trainer_id = t.id
    WHERE tu.username = 'test5';
    
    IF v_trainer_id IS NULL THEN
        RAISE NOTICE '❌ test5 trainer not found!';
        RETURN;
    END IF;
    
    IF v_user_id IS NULL THEN
        RAISE NOTICE '⚠️ test5 has no user_stats.user_id - achievements may not work';
    END IF;
    
    RAISE NOTICE '🔍 Processing achievements for test5:';
    RAISE NOTICE '   - test_username.id: %', v_test_user_id;
    RAISE NOTICE '   - trainer.id: %', v_trainer_id;
    RAISE NOTICE '   - user_stats.user_id: %', v_user_id;
    
    -- Call achievement function with the user_id from user_stats
    IF v_user_id IS NOT NULL THEN
        FOR v_result IN 
            SELECT * FROM check_and_award_achievements(v_user_id, v_trainer_id)
        LOOP
            RAISE NOTICE '🎉 Unlocked: % - % (% points)', 
                v_result.title, 
                v_result.description,
                v_result.points;
        END LOOP;
    ELSE
        RAISE NOTICE '❌ Cannot award achievements - user_id is NULL';
    END IF;
END $$;

-- Step 7: Final verification - show all achievements for test5
SELECT 
    '=== Final Check: test5 Achievements ===' as step,
    tu.username,
    a.achievement_key,
    a.title,
    a.points,
    ua.unlocked_at
FROM test_username tu
JOIN trainers t ON t.test_user_id = tu.id
JOIN user_achievements ua ON ua.trainer_id = t.id
JOIN achievements a ON a.id = ua.achievement_id
WHERE tu.username = 'test5'
ORDER BY ua.unlocked_at DESC;

-- Step 8: Test the function as the frontend will call it
SELECT 
    '=== Final Test: Frontend Call Simulation ===' as step,
    'Simulating: get_user_achievements(currentAppUser.id)' as simulation,
    tu.id as passed_user_id,
    COUNT(*) as achievements_returned
FROM test_username tu
CROSS JOIN LATERAL get_user_achievements(tu.id) gua
WHERE tu.username = 'test5'
GROUP BY tu.id;

SELECT 'Fix applied! Now test the milestones modal in the app.' as status;
