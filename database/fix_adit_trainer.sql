-- FIX: Link Adit's trainer to their test_username account
-- This fixes the bug where user_id was NULL during signup

-- Step 1: First, let's verify the test_username record exists
SELECT 
    id,
    username,
    'Found in test_username' as status
FROM test_username 
WHERE username = 'Adit';

-- Step 2: Check current trainer status
SELECT 
    t.id as trainer_id,
    t.name as trainer_name,
    t.user_id,
    t.test_user_id,
    'Current trainer status' as note
FROM trainers t
WHERE t.name = 'Adit';

-- Step 3: Update using the ID that actually exists
-- Find the correct test_username.id for user 'Adit' and use it
UPDATE trainers
SET user_id = (SELECT id FROM test_username WHERE username = 'Adit')
WHERE name = 'Adit';

-- Step 4: Verify the fix worked
SELECT 
    t.id as trainer_id,
    t.name as trainer_name,
    t.user_id,
    t.test_user_id,
    tu.username,
    tu.id as test_username_id,
    CASE 
        WHEN t.user_id = tu.id THEN '✅ FIXED'
        ELSE '❌ STILL BROKEN'
    END as status
FROM trainers t
LEFT JOIN test_username tu ON t.user_id = tu.id
WHERE t.name = 'Adit';
