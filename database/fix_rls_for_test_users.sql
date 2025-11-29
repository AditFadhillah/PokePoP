-- Fix RLS policies for test_username users
-- The current policies use auth.uid() which doesn't work with test_username authentication

-- Step 1: Drop existing restrictive policies on user_stats
DROP POLICY IF EXISTS "Users can view their own stats" ON user_stats;
DROP POLICY IF EXISTS "Users can insert their own stats" ON user_stats;
DROP POLICY IF EXISTS "Users can update their own stats" ON user_stats;

-- Step 2: Create more permissive policies that work with test_username
-- These allow anyone to read/write user_stats (suitable for development/testing)

CREATE POLICY "Allow all to view user_stats"
    ON user_stats
    FOR SELECT
    USING (true);

CREATE POLICY "Allow all to insert user_stats"
    ON user_stats
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Allow all to update user_stats"
    ON user_stats
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow all to delete user_stats"
    ON user_stats
    FOR DELETE
    USING (true);

-- Step 3: Fix user_achievements policies as well
DROP POLICY IF EXISTS "Users can view achievements" ON user_achievements;
DROP POLICY IF EXISTS "Users can update achievements" ON user_achievements;
DROP POLICY IF EXISTS "Users can insert achievements" ON user_achievements;

CREATE POLICY "Allow all to view user_achievements"
    ON user_achievements
    FOR SELECT
    USING (true);

CREATE POLICY "Allow all to insert user_achievements"
    ON user_achievements
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Allow all to update user_achievements"
    ON user_achievements
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow all to delete user_achievements"
    ON user_achievements
    FOR DELETE
    USING (true);

-- Note: For production, you would want to implement proper RLS based on test_username.id
-- But for development/testing, allowing all access is simpler

SELECT '✅ Fixed RLS policies for test_username users!' as status;
