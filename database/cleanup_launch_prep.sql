-- LAUNCH PREP: Clean up data before launch
-- Keep only: JuicyJulie, Usama, nana, mads_norregaard
-- Run each section one at a time and verify results

-- ============================================================================
-- STEP 1: Clean pokemon_inventory (uses trainer_id)
-- ============================================================================
-- First, let's see what will be deleted
SELECT COUNT(*) as "Records to delete from pokemon_inventory"
FROM pokemon_inventory
WHERE trainer_id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);

-- DELETE pokemon_inventory records (UNCOMMENT TO EXECUTE)

DELETE FROM pokemon_inventory
WHERE trainer_id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);


-- ============================================================================
-- STEP 2: Clean user_achievements (uses trainer_id)
-- ============================================================================
SELECT COUNT(*) as "Records to delete from user_achievements"
FROM user_achievements
WHERE trainer_id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);

-- DELETE user_achievements records (UNCOMMENT TO EXECUTE)
/*
DELETE FROM user_achievements
WHERE trainer_id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);
*/

-- ============================================================================
-- STEP 3: Clean user_stats (uses trainer_id)
-- ============================================================================
SELECT COUNT(*) as "Records to delete from user_stats"
FROM user_stats
WHERE trainer_id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);

-- DELETE user_stats records (UNCOMMENT TO EXECUTE)
/*
DELETE FROM user_stats
WHERE trainer_id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);
*/

-- ============================================================================
-- STEP 4: trainer_region_progress is a VIEW - it will auto-update when you delete trainers
-- ============================================================================
-- NO ACTION NEEDED - this is a view that aggregates data from other tables
-- It will automatically reflect changes when you delete trainers and pokemon

-- ============================================================================
-- STEP 5: Clean usage_sessions (uses username, which is trainer name)
-- ============================================================================
SELECT COUNT(*) as "Records to delete from usage_sessions"
FROM usage_sessions
WHERE username NOT IN ('JuicyJulie', 'Usama', 'nana', 'mads_norregaard');

-- DELETE usage_sessions records (UNCOMMENT TO EXECUTE)
/*
DELETE FROM usage_sessions
WHERE username NOT IN ('JuicyJulie', 'Usama', 'nana', 'mads_norregaard');
*/

-- ============================================================================
-- STEP 6: Clean testPlayerTable (if it has trainer or user references)
-- ============================================================================
-- Note: Check if this table has trainer_id or user_id columns
-- Uncomment and modify based on your table structure
/*
SELECT COUNT(*) as "Records to delete from testPlayerTable"
FROM testPlayerTable
WHERE trainer_id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);
*/

-- DELETE testPlayerTable records (UNCOMMENT TO EXECUTE)
/*
DELETE FROM testPlayerTable
WHERE trainer_id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);
*/

-- ============================================================================
-- STEP 7: Clean testcount (if it has trainer or user references)
-- ============================================================================
-- Note: Check if this table has trainer_id or user_id columns
-- Uncomment and modify based on your table structure
/*
SELECT COUNT(*) as "Records to delete from testcount"
FROM testcount
WHERE trainer_id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);
*/

-- DELETE testcount records (UNCOMMENT TO EXECUTE)
/*
DELETE FROM testcount
WHERE trainer_id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);
*/

-- ============================================================================
-- STEP 8: Clean trainers table (SECOND TO LAST - after all child tables)
-- ============================================================================
SELECT COUNT(*) as "Trainers to delete"
FROM trainers
WHERE id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);

-- DELETE trainers (UNCOMMENT TO EXECUTE - DO THIS LAST)
/*
DELETE FROM trainers
WHERE id NOT IN (
    'ff231a46-d179-4d60-b40c-9f1e4f6b80a7',  -- JuicyJulie
    'a0b26ad8-08f8-4d2a-8022-e40473f4ef55',  -- Usama
    '397ee476-e926-4a68-b098-cd2db2081190',  -- nana
    'fa07d98f-02dd-4e12-89e1-fccbfc683514'   -- mads_norregaard
);
*/

-- ============================================================================
-- STEP 9: Clean test_username (ABSOLUTE LAST - trainers reference this)
SELECT COUNT(*) as "Test users to delete"
FROM test_username
WHERE id NOT IN (
    'cab5f19c-519a-4cf2-af14-c29daf5a4596',  -- JuicyJulie user_id
    '9c11ef43-3f83-4d8f-9bf1-c668df19ec7b',  -- Usama user_id
    'f35930e0-ef90-45d6-8863-1d07bc370a70',  -- nana user_id
    '99c7e96c-8666-40d3-a91c-e6a9b92ecc57'   -- mads_norregaard user_id
);

-- DELETE test_username records (UNCOMMENT TO EXECUTE)
/*
DELETE FROM test_username
WHERE id NOT IN (
    'cab5f19c-519a-4cf2-af14-c29daf5a4596',  -- JuicyJulie user_id
    '9c11ef43-3f83-4d8f-9bf1-c668df19ec7b',  -- Usama user_id
    'f35930e0-ef90-45d6-8863-1d07bc370a70',  -- nana user_id
    '99c7e96c-8666-40d3-a91c-e6a9b92ecc57'   -- mads_norregaard user_id
);
*/

-- ============================================================================
-- VERIFICATION: Check remaining records
-- ============================================================================
SELECT 'trainers' as table_name, COUNT(*) as remaining_records FROM trainers
UNION ALL
SELECT 'pokemon_inventory', COUNT(*) FROM pokemon_inventory
UNION ALL
SELECT 'user_achievements', COUNT(*) FROM user_achievements
UNION ALL
SELECT 'user_stats', COUNT(*) FROM user_stats
UNION ALL
SELECT 'usage_sessions', COUNT(*) FROM usage_sessions
UNION ALL
SELECT 'test_username', COUNT(*) FROM test_username
UNION ALL
SELECT 'trainer_region_progress (VIEW)', COUNT(*) FROM trainer_region_progress;

-- Show the 4 trainers that should remain
SELECT id, name, total_points, achievement_points, team, created_at
FROM trainers
ORDER BY name;

-- ============================================================================
-- IMPORTANT NOTES:
-- ============================================================================
-- Tables that DON'T need cleaning (they're shared/reference data):
--   - achievements (shared achievement definitions)
--   - programming_tasks (shared task definitions)
--   - pokemon_regions (shared region data - if it exists)
--
-- VIEWS that will auto-update (DO NOT delete from these):
--   - trainer_region_progress (VIEW - aggregates trainer pokemon by region)
--   - team_leaderboard (VIEW - calculates team rankings)
--   - trainer_leaderboard (VIEW - calculates trainer rankings)
--   - usage_session_stats (VIEW - aggregates session statistics)
--
-- Deletion order MUST be:
--   1. Child tables (pokemon_inventory, user_achievements, user_stats, usage_sessions)
--   2. testPlayerTable and testcount (if they exist and have trainer references)
--   3. trainers (SECOND TO LAST)
--   4. test_username (ABSOLUTE LAST)
-- ============================================================================
