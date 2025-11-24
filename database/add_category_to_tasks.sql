-- Add category column to programming_tasks table to link tasks with game regions
-- Run this in your Supabase SQL Editor

-- Add category column
ALTER TABLE public.programming_tasks 
ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'Forest';

-- Update existing tasks with categories based on difficulty/topic
-- Forest Region: Basic Loops (Tasks 1, 3, 9, 12, 15, 18)
UPDATE public.programming_tasks 
SET category = 'Forest'
WHERE title IN (
    'Count Vowels in String',
    'Sum List with Loop',
    'Nested Loop Pattern',
    'Find Even Numbers',
    'Nested Loop Sum',
    'Loop Through Dictionary'
);

-- Beach Region: Dictionaries (Tasks 2, 4, 7, 10, 13, 16, 20)
UPDATE public.programming_tasks 
SET category = 'Beach'
WHERE title IN (
    'Dictionary Key Check',
    'Reverse Dictionary',
    'Count Words in Dictionary',
    'Dictionary Merge',
    'Dictionary from Two Lists',
    'Get Dictionary Keys',
    'Nested Dictionary Access'
);

-- Volcano Region: Regex (Tasks 5, 8, 11, 14, 17, 19)
UPDATE public.programming_tasks 
SET category = 'Volcano'
WHERE title IN (
    'Find Email Pattern',
    'Extract Phone Numbers',
    'Replace Digits',
    'Validate Username',
    'Split by Pattern',
    'Find Hashtags'
);

-- Swamp Region: Advanced Topics - Tuples & Special (Tasks 6, 21, 22, 23, 24)
UPDATE public.programming_tasks 
SET category = 'Swamp'
WHERE title IN (
    'Multiplication Table',
    'Tuple Unpacking',
    'Tuple to Lowercase List',
    'Reverse Dictionary',
    'DNA to mRNA Transcription'
);

-- Verify the categorization
SELECT 
    category,
    COUNT(*) as task_count,
    string_agg(title, ', ' ORDER BY title) as tasks
FROM public.programming_tasks
GROUP BY category
ORDER BY category;

-- Show all tasks with their categories
SELECT category, title, description
FROM public.programming_tasks
ORDER BY category, title;
