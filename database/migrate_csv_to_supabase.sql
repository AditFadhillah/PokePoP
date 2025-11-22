-- Migration Script: Import CSV data into Supabase (EXACT MATCH)
-- This script clears existing data and imports your exact CSV test data
-- Run this in your Supabase SQL Editor

-- IMPORTANT: This will DELETE all existing data and replace it with CSV data!
-- Make sure you have a backup if you need it.

-- PREREQUISITE CHECK: You need at least one user in auth.users
-- Run this query first to check if you have users:
-- SELECT id, email FROM auth.users;

-- If you don't have any users, you have two options:
-- Option 1: Create a user through Supabase Dashboard (Authentication > Users > Add user)
-- Option 2: Temporarily disable RLS (see below)

-- OPTION 2: Temporarily disable RLS for import (ONLY for development/testing)
-- Uncomment these lines if you need to import without authentication:
ALTER TABLE public.trainers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pokemon_inventory DISABLE ROW LEVEL SECURITY;
-- (Remember to re-enable after import!)

-- Step 1: Clear existing data (CASCADE will also delete related pokemon)
DELETE FROM public.pokemon_inventory;
DELETE FROM public.trainers;

-- Step 2: Insert trainers matching your CSV exactly
-- CSV has trainer_id 1 and 2, we'll use the UUIDs from your Supabase
-- Mapping: CSV id=1 -> trainer1, CSV id=2 -> trainer2

DO $$
DECLARE
    current_user_id UUID;
    trainer1_uuid UUID := '581f596c-20d9-4401-808a-a8892c1093c2'::UUID;
    trainer2_uuid UUID := '5b17619d-72b2-41c4-a10f-3f6199d6529f'::UUID;
BEGIN
    -- Try to get the current authenticated user
    current_user_id := auth.uid();
    
    -- If no authenticated user, get the first user from auth.users
    IF current_user_id IS NULL THEN
        SELECT id INTO current_user_id FROM auth.users LIMIT 1;
    END IF;
    
    -- If still no user found, raise an error
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'No user found in auth.users. Please create a user first or disable RLS temporarily.';
    END IF;
    
    RAISE NOTICE 'Using user_id: %', current_user_id;
    
    -- Insert trainers matching CSV structure EXACTLY
    -- CSV: id=1, name=trainer1, total_points=1600
    INSERT INTO public.trainers (id, user_id, name, total_points, created_at, updated_at)
    VALUES 
        (
            trainer1_uuid,
            current_user_id, 
            'trainer1',  -- Exact name from CSV
            1600,        -- Exact points from CSV
            '2025-10-28 00:00:00Z'::TIMESTAMPTZ,
            NOW()
        ),
        -- CSV: id=2, name=trainer2, total_points=900
        (
            trainer2_uuid,
            current_user_id, 
            'trainer2',  -- Exact name from CSV
            900,         -- Exact points from CSV
            '2025-10-28 00:00:00Z'::TIMESTAMPTZ,
            NOW()
        );
    
    RAISE NOTICE 'Trainers inserted: trainer1 (1600 pts), trainer2 (900 pts)';
END $$;

-- Step 3: Insert Pokemon inventory data EXACTLY from CSV
-- CSV trainer_id=1 maps to trainer1 UUID
-- CSV trainer_id=2 maps to trainer2 UUID

INSERT INTO public.pokemon_inventory (trainer_id, pokemon_name, level, points, captured_at)
VALUES 
    -- trainer1's Pokemon (CSV trainer_id=1, total should be 1600 points)
    ('581f596c-20d9-4401-808a-a8892c1093c2', 'CATERPIE', 2, 200, '2025-10-28 00:00:00Z'),
    ('581f596c-20d9-4401-808a-a8892c1093c2', 'CATERPIE', 1, 100, '2025-10-28 01:00:00Z'),
    ('581f596c-20d9-4401-808a-a8892c1093c2', 'BULBASAUR', 3, 300, '2025-10-28 02:00:00Z'),
    ('581f596c-20d9-4401-808a-a8892c1093c2', 'EEVEE', 4, 400, '2025-10-28 03:00:00Z'),
    ('581f596c-20d9-4401-808a-a8892c1093c2', 'VULPIX', 2, 200, '2025-10-28 04:00:00Z'),
    ('581f596c-20d9-4401-808a-a8892c1093c2', 'PIDGEY', 1, 100, '2025-10-28 05:00:00Z'),
    ('581f596c-20d9-4401-808a-a8892c1093c2', 'CATERPIE', 3, 300, '2025-10-28 06:00:00Z'),
    -- Total for trainer1: 200+100+300+400+200+100+300 = 1600 ✓
    
    -- trainer2's Pokemon (CSV trainer_id=2, total should be 900 points)
    ('5b17619d-72b2-41c4-a10f-3f6199d6529f', 'RATTATA', 2, 200, '2025-10-28 07:00:00Z'),
    ('5b17619d-72b2-41c4-a10f-3f6199d6529f', 'PIDGEY', 3, 300, '2025-10-28 08:00:00Z'),
    ('5b17619d-72b2-41c4-a10f-3f6199d6529f', 'EEVEE', 2, 200, '2025-10-28 09:00:00Z'),
    ('5b17619d-72b2-41c4-a10f-3f6199d6529f', 'VULPIX', 2, 200, '2025-10-28 10:00:00Z')
        -- Total for trainer2: 200+300+200+200 = 900 ✓
;

-- Step 4: Verify the data matches CSV exactly
SELECT 
    t.name as trainer_name,
    t.total_points,
    COUNT(pi.id) as pokemon_count,
    COALESCE(SUM(pi.points), 0) as calculated_points
FROM public.trainers t
LEFT JOIN public.pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.total_points
ORDER BY t.name;

-- Expected output:
-- trainer1 | 1600 | 7 | 1600
-- trainer2 | 900  | 4 | 900

-- Step 5: View all pokemon by trainer (should match CSV)
SELECT 
    t.name as trainer_name,
    pi.pokemon_name,
    pi.level,
    pi.points,
    pi.captured_at
FROM public.pokemon_inventory pi
JOIN public.trainers t ON pi.trainer_id = t.id
ORDER BY t.name, pi.captured_at;

-- Expected total records: 11 Pokemon
-- trainer1: 7 Pokemon (CATERPIE x3, BULBASAUR, EEVEE, VULPIX, PIDGEY)
-- trainer2: 4 Pokemon (RATTATA, PIDGEY, EEVEE, VULPIX)

-- Additional verification query
SELECT 
    'CSV Match Check' as check_type,
    CASE 
        WHEN COUNT(*) = 2 THEN '✓ Correct number of trainers'
        ELSE '✗ Wrong number of trainers'
    END as trainers_status,
    CASE 
        WHEN SUM(CASE WHEN name = 'trainer1' AND total_points = 1600 THEN 1 ELSE 0 END) = 1 
        THEN '✓ trainer1 data correct'
        ELSE '✗ trainer1 data incorrect'
    END as trainer1_status,
    CASE 
        WHEN SUM(CASE WHEN name = 'trainer2' AND total_points = 900 THEN 1 ELSE 0 END) = 1 
        THEN '✓ trainer2 data correct'
        ELSE '✗ trainer2 data incorrect'
    END as trainer2_status
FROM public.trainers;

SELECT 
    'Pokemon Count Check' as check_type,
    CASE 
        WHEN COUNT(*) = 11 THEN '✓ All 11 Pokemon imported'
        ELSE CONCAT('✗ Expected 11, got ', COUNT(*))
    END as status
FROM public.pokemon_inventory;

-- If you disabled RLS earlier, re-enable it now:
ALTER TABLE public.trainers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pokemon_inventory ENABLE ROW LEVEL SECURITY;

-- SUCCESS! Your Supabase database now matches your CSV files exactly.
;

-- Step 3: Verify the data was inserted correctly
SELECT 
    t.name as trainer_name,
    t.total_points,
    COUNT(pi.id) as pokemon_count
FROM public.trainers t
LEFT JOIN public.pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.total_points
ORDER BY t.total_points DESC;

-- Step 4: View all pokemon by trainer
SELECT 
    t.name as trainer_name,
    pi.pokemon_name,
    pi.level,
    pi.points,
    pi.captured_at
FROM public.pokemon_inventory pi
JOIN public.trainers t ON pi.trainer_id = t.id
ORDER BY t.name, pi.captured_at;

-- Additional helpful queries:

-- View the leaderboard
SELECT * FROM public.trainer_leaderboard;

-- Check if triggers are working (total_points should match sum of pokemon points)
SELECT 
    t.id,
    t.name,
    t.total_points as recorded_points,
    COALESCE(SUM(pi.points), 0) as calculated_points,
    CASE 
        WHEN t.total_points = COALESCE(SUM(pi.points), 0) THEN '✓ Match'
        ELSE '✗ Mismatch'
    END as status
FROM public.trainers t
LEFT JOIN public.pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.total_points;
