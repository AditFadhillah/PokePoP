-- Add id column to test_username table and connect it to trainers
-- Run this in your Supabase SQL Editor

-- Add id column to test_username if it doesn't exist (without PRIMARY KEY constraint if already exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'test_username' AND column_name = 'id'
    ) THEN
        ALTER TABLE public.test_username 
        ADD COLUMN id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL;
    END IF;
END $$;

-- Update trainers table to reference test_username instead of auth.users
-- Drop the old foreign key constraint if it exists
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'trainers_user_id_fkey' 
        AND table_name = 'trainers'
    ) THEN
        ALTER TABLE public.trainers DROP CONSTRAINT trainers_user_id_fkey;
    END IF;
END $$;

-- Set existing trainers' user_id to NULL (they were referencing auth.users, not test_username)
-- This allows the new foreign key constraint to be added
UPDATE public.trainers 
SET user_id = NULL 
WHERE user_id IS NOT NULL 
AND user_id NOT IN (SELECT id FROM public.test_username);

-- Add new foreign key constraint linking user_id to test_username.id
ALTER TABLE public.trainers 
ADD CONSTRAINT trainers_user_id_fkey 
FOREIGN KEY (user_id) 
REFERENCES public.test_username(id) 
ON DELETE CASCADE;

-- Add RLS policies for trainers table
ALTER TABLE public.trainers ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist, then recreate them
DROP POLICY IF EXISTS "Allow public insert on trainers" ON public.trainers;
DROP POLICY IF EXISTS "Allow public read on trainers" ON public.trainers;
DROP POLICY IF EXISTS "Allow public update on trainers" ON public.trainers;

CREATE POLICY "Allow public insert on trainers"
ON public.trainers
FOR INSERT
TO PUBLIC
WITH CHECK (true);

CREATE POLICY "Allow public read on trainers"
ON public.trainers
FOR SELECT
TO PUBLIC
USING (true);

CREATE POLICY "Allow public update on trainers"
ON public.trainers
FOR UPDATE
TO PUBLIC
USING (true)
WITH CHECK (true);

-- Add comment to clarify the relationship
COMMENT ON COLUMN public.trainers.user_id IS 'References test_username.id (simple username/password auth)';
