-- Add app_users table for username/password authentication
-- This is separate from Supabase Auth and stores simple username/password login

CREATE TABLE IF NOT EXISTS public.app_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for app_users
ALTER TABLE public.app_users ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read app_users (for login verification)
CREATE POLICY "Allow public read on app_users"
ON public.app_users
FOR SELECT
TO PUBLIC
USING (true);

-- Allow anyone to insert new users (for signup)
CREATE POLICY "Allow public insert on app_users"
ON public.app_users
FOR INSERT
TO PUBLIC
WITH CHECK (true);

-- Update the trainers table to use app_users instead of auth.users
-- Note: This keeps the existing user_id column but it will now reference app_users.id
-- You may want to clear existing data if switching authentication methods

-- Add a comment to clarify the relationship
COMMENT ON COLUMN public.trainers.user_id IS 'References app_users.id (custom auth system)';
COMMENT ON COLUMN public.pokemon_inventory.trainer_id IS 'References trainers.id';
