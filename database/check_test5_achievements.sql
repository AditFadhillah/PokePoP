-- Check and fix achievements for trainer test5
-- This script will:
-- 1. Check test5's current status
-- 2. Backfill any missing achievements
-- 3. Verify the milestone system is working

-- Step 1: Check current state of test5
SELECT 
    'Current State of test5' as info,
    u.id as user_id,
    t.id as trainer_id,
    t.name as trainer_name,
    u.email as username,
    t.total_points,
    t.achievement_points
FROM auth.users u
JOIN trainers t ON t.user_id = u.id
WHERE u.email = 'test5';

-- Step 2: Check test5's user_stats
SELECT 
    'test5 User Stats' as info,
    us.*
FROM auth.users u
JOIN user_stats us ON us.user_id = u.id
WHERE u.email = 'test5';

-- Step 3: Check test5's pokemon captures
SELECT 
    'test5 Pokemon Inventory' as info,
    COUNT(*) as pokemon_count,
    COUNT(DISTINCT pokemon_name) as unique_pokemon
FROM auth.users u
JOIN trainers t ON t.user_id = u.id
JOIN pokemon_inventory pi ON pi.trainer_id = t.id
WHERE u.email = 'test5';

-- Step 4: Check currently unlocked achievements for test5
SELECT 
    'test5 Current Achievements' as info,
    a.achievement_key,
    a.title,
    a.description,
    a.category,
    a.points,
    ua.unlocked_at
FROM auth.users u
JOIN user_achievements ua ON ua.user_id = u.id
JOIN achievements a ON a.id = ua.achievement_id
WHERE u.email = 'test5'
ORDER BY ua.unlocked_at DESC;

-- Step 5: Identify which achievements test5 should have but doesn't
SELECT 
    'Achievements test5 SHOULD have' as info,
    a.achievement_key,
    a.title,
    a.description,
    a.category,
    a.requirement_value,
    a.points,
    CASE 
        WHEN a.category = 'first_capture' THEN 
            CASE WHEN us.total_captures >= 1 THEN 'SHOULD BE UNLOCKED' ELSE 'Not eligible' END
        WHEN a.category = 'total_captures' THEN 
            CASE WHEN us.total_captures >= a.requirement_value 
                THEN 'SHOULD BE UNLOCKED (has ' || us.total_captures || ' captures)'
                ELSE 'Not eligible (has ' || us.total_captures || ' captures, needs ' || a.requirement_value || ')'
            END
        WHEN a.category = 'login_streak' THEN 
            CASE WHEN us.current_login_streak >= a.requirement_value 
                THEN 'SHOULD BE UNLOCKED (streak: ' || us.current_login_streak || ')'
                ELSE 'Not eligible (streak: ' || us.current_login_streak || ', needs ' || a.requirement_value || ')'
            END
        WHEN a.category = 'duration' THEN 
            CASE WHEN us.total_duration_minutes >= a.requirement_value 
                THEN 'SHOULD BE UNLOCKED (playtime: ' || us.total_duration_minutes || ' min)'
                ELSE 'Not eligible (playtime: ' || us.total_duration_minutes || ' min, needs ' || a.requirement_value || ')'
            END
        ELSE 'Unknown category'
    END as eligibility_status
FROM auth.users u
JOIN user_stats us ON us.user_id = u.id
CROSS JOIN achievements a
LEFT JOIN user_achievements ua ON ua.user_id = u.id AND ua.achievement_id = a.id
WHERE u.email = 'test5'
    AND ua.id IS NULL  -- Not yet unlocked
    AND (
        (a.category = 'first_capture' AND us.total_captures >= 1) OR
        (a.category = 'total_captures' AND us.total_captures >= a.requirement_value) OR
        (a.category = 'login_streak' AND us.current_login_streak >= a.requirement_value) OR
        (a.category = 'duration' AND us.total_duration_minutes >= a.requirement_value)
    )
ORDER BY a.category, a.requirement_value;

-- Step 6: Backfill missing achievements for test5
DO $$
DECLARE
    v_user_id UUID;
    v_trainer_id UUID;
    v_result RECORD;
BEGIN
    -- Get test5's IDs
    SELECT u.id, t.id INTO v_user_id, v_trainer_id
    FROM auth.users u
    JOIN trainers t ON t.user_id = u.id
    WHERE u.email = 'test5';
    
    IF v_user_id IS NULL THEN
        RAISE NOTICE 'User test5 not found!';
        RETURN;
    END IF;
    
    RAISE NOTICE 'Processing achievements for test5 (user_id: %, trainer_id: %)', v_user_id, v_trainer_id;
    
    -- Call the achievement checking function
    FOR v_result IN 
        SELECT * FROM check_and_award_achievements(v_user_id, v_trainer_id)
    LOOP
        RAISE NOTICE '🎉 Unlocked: % - % (% points)', 
            v_result.title, 
            v_result.description,
            v_result.points;
    END LOOP;
    
    RAISE NOTICE 'Achievement backfill completed for test5!';
END $$;

-- Step 7: Verify achievements after backfill
SELECT 
    'test5 Achievements After Backfill' as info,
    a.achievement_key,
    a.title,
    a.category,
    a.points,
    ua.unlocked_at
FROM auth.users u
JOIN user_achievements ua ON ua.user_id = u.id
JOIN achievements a ON a.id = ua.achievement_id
WHERE u.email = 'test5'
ORDER BY ua.unlocked_at DESC;

-- Step 8: Verify trainer points were updated correctly
SELECT 
    'test5 Final Trainer Stats' as info,
    t.name,
    t.total_points,
    t.achievement_points,
    (SELECT SUM(pi.points) FROM pokemon_inventory pi WHERE pi.trainer_id = t.id) as pokemon_points,
    (SELECT COUNT(*) FROM user_achievements ua WHERE ua.trainer_id = t.id) as achievement_count
FROM auth.users u
JOIN trainers t ON t.user_id = u.id
WHERE u.email = 'test5';
