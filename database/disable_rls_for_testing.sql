-- Temporarily disable RLS for development/testing
-- This allows you to insert/update data without authentication
-- WARNING: Only use this in development! Re-enable before production!

-- Disable RLS on trainers table
ALTER TABLE public.trainers DISABLE ROW LEVEL SECURITY;

-- Disable RLS on pokemon_inventory table
ALTER TABLE public.pokemon_inventory DISABLE ROW LEVEL SECURITY;

-- Verify RLS is disabled
SELECT 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('trainers', 'pokemon_inventory');

-- Expected output: rls_enabled should be 'false' for both tables

-- When you're done testing and want to re-enable RLS, run:
-- ALTER TABLE public.trainers ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.pokemon_inventory ENABLE ROW LEVEL SECURITY;
