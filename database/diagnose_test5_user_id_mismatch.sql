-- Check the relationship between test_username and auth.users for test5

-- Step 1: Check test_username table for test5
SELECT 
    '=== test_username table ===' as info,
    tu.id,
    tu.username,
    tu.password
FROM test_username tu
WHERE tu.username = 'test5';

-- Step 2: Check if there's a corresponding auth.users entry
SELECT 
    '=== auth.users table ===' as info,
    u.id,
    u.email,
    u.created_at
FROM auth.users u
WHERE u.email = 'test5';

-- Step 3: Check trainers table - which user_id does it reference?
SELECT 
    '=== trainers table ===' as info,
    t.id as trainer_id,
    t.user_id,
    t.test_user_id,
    t.name,
    t.total_points,
    t.achievement_points,
    'Checking which user_id field is used' as note
FROM trainers t
WHERE t.name = 'test5' OR t.name LIKE '%test5%';

-- Step 4: Check user_achievements - which user_id does it use?
SELECT 
    '=== user_achievements table ===' as info,
    ua.id,
    ua.user_id,
    ua.trainer_id,
    ua.achievement_id,
    'Does user_id match test_username.id or auth.users.id?' as question
FROM user_achievements ua
JOIN trainers t ON t.id = ua.trainer_id
WHERE t.name = 'test5' OR t.name LIKE '%test5%';

-- Step 5: Check user_stats - which user_id does it use?
SELECT 
    '=== user_stats table ===' as info,
    us.user_id,
    us.trainer_id,
    us.total_captures,
    'Does user_id match test_username.id or auth.users.id?' as question
FROM user_stats us
JOIN trainers t ON t.id = us.trainer_id
WHERE t.name = 'test5' OR t.name LIKE '%test5%';

-- Step 6: Try to find test5 using test_user_id field
SELECT 
    '=== Using test_user_id field ===' as info,
    t.id as trainer_id,
    t.test_user_id,
    t.name,
    tu.username,
    (SELECT COUNT(*) FROM user_achievements WHERE trainer_id = t.id) as achievement_count,
    (SELECT COUNT(*) FROM user_stats WHERE trainer_id = t.id) as stats_count
FROM trainers t
LEFT JOIN test_username tu ON tu.id = t.test_user_id
WHERE tu.username = 'test5';

-- Step 7: Critical diagnosis - get the actual user_id being passed from frontend
-- The MilestonesModal receives userId from currentAppUser?.id
-- currentAppUser comes from test_username table
-- So we need to check if user_achievements uses test_username.id or auth.users.id

SELECT 
    '=== DIAGNOSIS ===' as info,
    tu.id as test_username_id,
    tu.username,
    t.id as trainer_id,
    t.name as trainer_name,
    t.user_id as trainer_user_id_field,
    t.test_user_id as trainer_test_user_id_field,
    us.user_id as user_stats_user_id,
    (SELECT COUNT(*) FROM user_achievements WHERE user_id = tu.id) as achievements_with_test_username_id,
    (SELECT COUNT(*) FROM user_achievements WHERE user_id = t.user_id) as achievements_with_auth_users_id,
    (SELECT COUNT(*) FROM user_achievements WHERE trainer_id = t.id) as achievements_by_trainer_id
FROM test_username tu
LEFT JOIN trainers t ON t.test_user_id = tu.id OR t.user_id = tu.id::text::uuid
LEFT JOIN user_stats us ON us.trainer_id = t.id
WHERE tu.username = 'test5';

-- Step 8: Show the mismatch
SELECT 
    '=== THE PROBLEM ===' as info,
    'Frontend passes: currentAppUser.id (from test_username)' as frontend,
    'Database expects: auth.users.id' as database,
    'Solution: Either link test_username.id to user_achievements OR change frontend' as fix;

-- Step 9: Check what the get_user_achievements function expects
SELECT 
    '=== Function Signature ===' as info,
    p.parameter_name,
    p.data_type,
    'get_user_achievements expects a UUID that matches user_achievements.user_id' as note
FROM information_schema.parameters p
WHERE p.specific_schema = 'public'
    AND p.routine_name = 'get_user_achievements'
    AND p.parameter_mode = 'IN'
ORDER BY p.ordinal_position;
