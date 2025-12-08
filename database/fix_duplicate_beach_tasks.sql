-- Fix duplicate Beach dictionary tasks in programming_tasks table
-- This script removes duplicate entries and keeps only one of each task

-- Step 1: Identify and delete duplicate "Dictionary Get with Default" tasks
-- Keep the one from 2025-12-08 13:10:41.493958+00 (id: 3f62bec8-5e74-48f5-b715-6dcd2e391c52)
-- Delete the one from 2025-12-08 13:18:32.143248+00 (id: 716f4243-569e-463a-bd5a-a4a842580eec)
DELETE FROM programming_tasks 
WHERE id = '716f4243-569e-463a-bd5a-a4a842580eec' 
AND title = 'Dictionary Get with Default';

-- Step 2: Identify and delete duplicate "Dictionary Values Sum" tasks
-- Keep the one from 2025-12-08 13:10:41.493958+00 (id: 703f0d14-3a65-4020-96eb-a9df84e378e6)
-- Delete the one from 2025-12-08 13:18:32.143248+00 (id: 46114428-79a8-4219-b0d5-7e517221f5b9)
DELETE FROM programming_tasks 
WHERE id = '46114428-79a8-4219-b0d5-7e517221f5b9' 
AND title = 'Dictionary Values Sum';

-- Step 3: Identify and delete duplicate "Dictionary Update Value" tasks
-- Keep the one from 2025-12-08 13:10:41.493958+00 (id: f93df143-e3c0-42ad-baa2-519a78301a7a)
-- Delete the one from 2025-12-08 13:18:32.143248+00 (id: 126b12d4-69b4-4540-a868-90652167ae1a)
DELETE FROM programming_tasks 
WHERE id = '126b12d4-69b4-4540-a868-90652167ae1a' 
AND title = 'Dictionary Update Value';

-- Verification query: Check remaining Beach tasks (should be 11 total)
SELECT COUNT(*) as beach_task_count 
FROM programming_tasks 
WHERE category = 'Beach';

-- Verification query: List all Beach tasks with their IDs and titles
SELECT id, title, created_at, category 
FROM programming_tasks 
WHERE category = 'Beach'
ORDER BY created_at;

-- Verification query: Check total task count (should be 34)
SELECT category, COUNT(*) as task_count 
FROM programming_tasks 
GROUP BY category
ORDER BY category;
