-- Fix permissions for trainer_leaderboard view
-- This allows anonymous users (guests) to view the leaderboard

-- Grant SELECT permission to anon (anonymous/guest users)
GRANT SELECT ON public.trainer_leaderboard TO anon;

-- Grant SELECT permission to authenticated users (logged in users)
GRANT SELECT ON public.trainer_leaderboard TO authenticated;

-- Verify the view is accessible
SELECT * FROM public.trainer_leaderboard LIMIT 6;
