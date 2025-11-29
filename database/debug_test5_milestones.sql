-- Debug script to check why test5's milestones aren't showing

-- Step 1: Find test5's user_id
SELECT 
    '=== Step 1: Find test5 user ===' as step,
    u.id as user_id,
    u.email,
    u.created_at
FROM auth.users u
WHERE u.email = 'test5' OR u.email LIKE '%test5%';

-- Step 2: Check if test5 has a trainer
SELECT 
    '=== Step 2: Check test5 trainer ===' as step,
    t.id as trainer_id,
    t.user_id,
    t.name as trainer_name,
    t.total_points,
    t.achievement_points,
    t.created_at
FROM auth.users u
JOIN trainers t ON t.user_id = u.id
WHERE u.email = 'test5' OR u.email LIKE '%test5%';

-- Step 3: Check if test5 has user_stats
SELECT 
    '=== Step 3: Check test5 user_stats ===' as step,
    us.id,
    us.user_id,
    us.trainer_id,
    us.total_captures,
    us.forest_captures,
    us.beach_captures,
    us.volcano_captures,
    us.swamp_captures,
    us.current_login_streak,
    us.total_duration_minutes
FROM auth.users u
JOIN user_stats us ON us.user_id = u.id
WHERE u.email = 'test5' OR u.email LIKE '%test5%';

-- Step 4: Check if test5 has captured any pokemon
SELECT 
    '=== Step 4: Check test5 pokemon captures ===' as step,
    COUNT(*) as total_pokemon,
    COUNT(DISTINCT pokemon_name) as unique_pokemon,
    SUM(points) as total_points
FROM auth.users u
JOIN trainers t ON t.user_id = u.id
JOIN pokemon_inventory pi ON pi.trainer_id = t.id
WHERE u.email = 'test5' OR u.email LIKE '%test5%';

-- Step 5: Check user_achievements table directly for test5
SELECT 
    '=== Step 5: Check user_achievements table ===' as step,
    ua.id,
    ua.user_id,
    ua.trainer_id,
    ua.achievement_id,
    ua.unlocked_at,
    a.achievement_key,
    a.title,
    a.points
FROM auth.users u
JOIN user_achievements ua ON ua.user_id = u.id
JOIN achievements a ON a.id = ua.achievement_id
WHERE u.email = 'test5' OR u.email LIKE '%test5%'
ORDER BY ua.unlocked_at DESC;

-- Step 6: Test the get_user_achievements function directly
-- First get the user_id
DO $$
DECLARE
    v_user_id UUID;
BEGIN
    SELECT u.id INTO v_user_id
    FROM auth.users u
    WHERE u.email = 'test5' OR u.email LIKE '%test5%'
    LIMIT 1;
    
    IF v_user_id IS NULL THEN
        RAISE NOTICE '=== Step 6: get_user_achievements test ===';
        RAISE NOTICE 'ERROR: test5 user not found!';
    ELSE
        RAISE NOTICE '=== Step 6: Testing get_user_achievements for user_id: % ===', v_user_id;
        
        -- Check if function returns any data
        PERFORM * FROM get_user_achievements(v_user_id);
        
        IF NOT FOUND THEN
            RAISE NOTICE 'get_user_achievements returned NO data for test5';
        ELSE
            RAISE NOTICE 'get_user_achievements returned data - see query results below';
        END IF;
    END IF;
END $$;

-- Actually run the function and show results
SELECT 
    '=== Step 6b: get_user_achievements results ===' as step,
    gua.*
FROM auth.users u
CROSS JOIN LATERAL get_user_achievements(u.id) gua
WHERE u.email = 'test5' OR u.email LIKE '%test5%';

-- Step 7: Check if the function signature matches what the frontend expects
SELECT 
    '=== Step 7: Check function signature ===' as step,
    routine_name,
    data_type,
    ordinal_position,
    parameter_name,
    parameter_mode
FROM information_schema.parameters
WHERE specific_schema = 'public'
    AND routine_name = 'get_user_achievements'
ORDER BY ordinal_position;

-- Step 8: List all achievements that exist in the system
SELECT 
    '=== Step 8: All available achievements ===' as step,
    achievement_key,
    title,
    category,
    requirement_value,
    points
FROM achievements
ORDER BY category, requirement_value;

-- Step 9: Check which achievements test5 SHOULD have based on stats
SELECT 
    '=== Step 9: Achievements test5 should have ===' as step,
    a.achievement_key,
    a.title,
    a.category,
    a.requirement_value,
    CASE 
        WHEN a.category = 'first_capture' AND us.total_captures >= 1 THEN '✓ ELIGIBLE'
        WHEN a.category = 'total_captures' AND us.total_captures >= a.requirement_value THEN '✓ ELIGIBLE (' || us.total_captures || ' captures)'
        WHEN a.category = 'login_streak' AND us.current_login_streak >= a.requirement_value THEN '✓ ELIGIBLE (streak: ' || us.current_login_streak || ')'
        WHEN a.category = 'duration' AND us.total_duration_minutes >= a.requirement_value THEN '✓ ELIGIBLE (' || us.total_duration_minutes || ' min)'
        ELSE '✗ Not eligible'
    END as eligibility,
    CASE 
        WHEN ua.id IS NOT NULL THEN '✓ Already unlocked'
        ELSE '✗ NOT UNLOCKED YET'
    END as unlock_status
FROM auth.users u
CROSS JOIN achievements a
JOIN user_stats us ON us.user_id = u.id
LEFT JOIN user_achievements ua ON ua.user_id = u.id AND ua.achievement_id = a.id
WHERE (u.email = 'test5' OR u.email LIKE '%test5%')
    AND (
        (a.category = 'first_capture' AND us.total_captures >= 1) OR
        (a.category = 'total_captures' AND us.total_captures >= a.requirement_value) OR
        (a.category = 'login_streak' AND us.current_login_streak >= a.requirement_value) OR
        (a.category = 'duration' AND us.total_duration_minutes >= a.requirement_value)
    )
ORDER BY 
    CASE WHEN ua.id IS NULL THEN 0 ELSE 1 END,
    a.category,
    a.requirement_value;

-- Step 10: Summary
SELECT 
    '=== SUMMARY for test5 ===' as summary,
    (SELECT COUNT(*) FROM auth.users WHERE email = 'test5' OR email LIKE '%test5%') as user_exists,
    (SELECT COUNT(*) FROM trainers t JOIN auth.users u ON t.user_id = u.id WHERE u.email = 'test5' OR u.email LIKE '%test5%') as has_trainer,
    (SELECT COUNT(*) FROM user_stats us JOIN auth.users u ON us.user_id = u.id WHERE u.email = 'test5' OR u.email LIKE '%test5%') as has_stats,
    (SELECT COALESCE(SUM(us.total_captures), 0) FROM user_stats us JOIN auth.users u ON us.user_id = u.id WHERE u.email = 'test5' OR u.email LIKE '%test5%') as total_captures,
    (SELECT COUNT(*) FROM user_achievements ua JOIN auth.users u ON ua.user_id = u.id WHERE u.email = 'test5' OR u.email LIKE '%test5%') as achievements_unlocked,
    (SELECT COUNT(*) FROM pokemon_inventory pi JOIN trainers t ON pi.trainer_id = t.id JOIN auth.users u ON t.user_id = u.id WHERE u.email = 'test5' OR u.email LIKE '%test5%') as pokemon_count;
