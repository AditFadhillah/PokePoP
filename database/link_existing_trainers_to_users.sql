-- Create usernames and passwords for existing trainers
-- Run this in your Supabase SQL Editor AFTER running connect_test_username_to_trainers.sql

-- First, check the existing trainers
-- SELECT * FROM trainers WHERE user_id IS NULL;

-- Create users for trainer1 and trainer2
INSERT INTO public.test_username (username, password)
VALUES 
  ('trainer1', 'password1'),
  ('trainer2', 'password2')
ON CONFLICT (username) DO NOTHING;

-- Link trainer1 to its user account
UPDATE public.trainers
SET user_id = (SELECT id FROM public.test_username WHERE username = 'trainer1')
WHERE name = 'trainer1' AND user_id IS NULL;

-- Link trainer2 to its user account  
UPDATE public.trainers
SET user_id = (SELECT id FROM public.test_username WHERE username = 'trainer2')
WHERE name = 'trainer2' AND user_id IS NULL;

-- Verify the linkage
SELECT 
  t.id as trainer_id,
  t.name as trainer_name,
  t.total_points,
  u.id as user_id,
  u.username
FROM trainers t
LEFT JOIN test_username u ON t.user_id = u.id
ORDER BY t.name;
