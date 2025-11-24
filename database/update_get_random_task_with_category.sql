-- Update get_random_task function to support region/category filtering
-- Run this in your Supabase SQL Editor

-- Drop old function versions
DROP FUNCTION IF EXISTS get_random_task();
DROP FUNCTION IF EXISTS get_random_task(TEXT);

-- Create updated function with optional category parameter
CREATE OR REPLACE FUNCTION get_random_task(task_category TEXT DEFAULT NULL)
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
    WHERE task_category IS NULL OR t.category = task_category
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Test the function
-- Get random task from any category
SELECT * FROM get_random_task();

-- Get random task from Forest region
SELECT * FROM get_random_task('Forest');

-- Get random task from Beach region
SELECT * FROM get_random_task('Beach');

-- Get random task from Volcano region
SELECT * FROM get_random_task('Volcano');

-- Get random task from Swamp region
SELECT * FROM get_random_task('Swamp');
