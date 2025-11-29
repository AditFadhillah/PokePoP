-- Update get_random_task function to exclude recently seen tasks
-- This prevents getting the same task twice in a row
-- Run this in your Supabase SQL Editor

-- Drop old function versions
DROP FUNCTION IF EXISTS get_random_task(TEXT);
DROP FUNCTION IF EXISTS get_random_task(TEXT, UUID[]);

-- Create updated function with optional category parameter and excluded task IDs
CREATE OR REPLACE FUNCTION get_random_task(
    task_category TEXT DEFAULT NULL,
    excluded_task_ids UUID[] DEFAULT ARRAY[]::UUID[]
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    starter_code TEXT,
    expected_output TEXT,
    category TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.title,
        t.description,
        t.starter_code,
        t.expected_output,
        t.category
    FROM public.programming_tasks t
    WHERE 
        (task_category IS NULL OR t.category = task_category)
        AND NOT (t.id = ANY(excluded_task_ids))
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_random_task(TEXT, UUID[]) TO authenticated;
GRANT EXECUTE ON FUNCTION get_random_task(TEXT, UUID[]) TO anon;

-- Test the function
-- Get random task from any category
SELECT * FROM get_random_task();

-- Get random task from Forest region (no exclusions)
SELECT * FROM get_random_task('Forest', ARRAY[]::UUID[]);

-- Example: Get random task, excluding specific UUIDs
-- Replace with actual task IDs from your programming_tasks table
-- SELECT * FROM get_random_task(NULL, ARRAY['actual-uuid-here', 'another-uuid-here']::UUID[]);
