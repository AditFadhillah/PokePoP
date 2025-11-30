-- COMPREHENSIVE FIX: Ensure all trainers have user_id set correctly
-- This fixes the signup bug where only test_user_id was being set

-- Step 1: Update any trainers where user_id is NULL but test_user_id is set
UPDATE trainers
SET user_id = test_user_id
WHERE user_id IS NULL 
  AND test_user_id IS NOT NULL;

-- Step 2: Verify all trainers are properly linked
SELECT 
    t.id as trainer_id,
    t.name as trainer_name,
    t.user_id,
    t.test_user_id,
    tu.username,
    CASE 
        WHEN t.user_id IS NULL THEN '❌ BROKEN - No user_id'
        WHEN t.user_id = tu.id THEN '✅ CORRECT'
        ELSE '⚠️ MISMATCH'
    END as status
FROM trainers t
LEFT JOIN test_username tu ON t.user_id = tu.id
ORDER BY t.created_at DESC;

-- Step 3: Check for any orphaned trainers (no matching test_username)
SELECT 
    t.id,
    t.name,
    t.user_id,
    'No matching test_username user' as issue
FROM trainers t
LEFT JOIN test_username tu ON t.user_id = tu.id
WHERE tu.id IS NULL;
