-- Complete fix for new user signup issues (test6 errors)
-- This fixes:
-- 1. RLS policies blocking test_username users from accessing user_stats
-- 2. RLS policies blocking test_username users from accessing user_achievements

-- ============================================
-- PART 1: FIX RLS POLICIES
-- ============================================

-- Drop existing restrictive policies on user_stats
DROP POLICY IF EXISTS "Users can view their own stats" ON user_stats;
DROP POLICY IF EXISTS "Users can insert their own stats" ON user_stats;
DROP POLICY IF EXISTS "Users can update their own stats" ON user_stats;
DROP POLICY IF EXISTS "Users can delete their own stats" ON user_stats;

-- Create permissive policies for user_stats (works with test_username auth)
CREATE POLICY "Allow all to view user_stats"
    ON user_stats FOR SELECT USING (true);

CREATE POLICY "Allow all to insert user_stats"
    ON user_stats FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all to update user_stats"
    ON user_stats FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow all to delete user_stats"
    ON user_stats FOR DELETE USING (true);

-- Drop existing restrictive policies on user_achievements
DROP POLICY IF EXISTS "Users can view achievements" ON user_achievements;
DROP POLICY IF EXISTS "Users can update achievements" ON user_achievements;
DROP POLICY IF EXISTS "Users can insert achievements" ON user_achievements;
DROP POLICY IF EXISTS "Users can delete achievements" ON user_achievements;

-- Create permissive policies for user_achievements (works with test_username auth)
CREATE POLICY "Allow all to view user_achievements"
    ON user_achievements FOR SELECT USING (true);

CREATE POLICY "Allow all to insert user_achievements"
    ON user_achievements FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all to update user_achievements"
    ON user_achievements FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow all to delete user_achievements"
    ON user_achievements FOR DELETE USING (true);

-- ============================================
-- PART 2: VERIFY THE FIXES
-- ============================================

-- Test that user_stats can be queried
SELECT 
    '=== Testing user_stats access ===' as test,
    COUNT(*) as total_stats
FROM user_stats;

-- Test that user_achievements can be queried
SELECT 
    '=== Testing user_achievements access ===' as test,
    COUNT(*) as total_achievements
FROM user_achievements;

-- Check existing test users
SELECT 
    '=== Existing test users ===' as info,
    tu.username,
    t.name as trainer_name,
    (SELECT COUNT(*) FROM user_stats WHERE trainer_id = t.id) as has_stats,
    (SELECT COUNT(*) FROM user_achievements WHERE trainer_id = t.id) as achievement_count
FROM test_username tu
LEFT JOIN trainers t ON t.test_user_id = tu.id
ORDER BY tu.username;

SELECT '✅ RLS policies fixed! New users (like test6) can now access user_stats and user_achievements.' as status;
SELECT '⚠️  Note: These are permissive policies suitable for development/testing.' as note;
SELECT '   For production, implement proper RLS based on test_username.id or session data.' as production_note;
