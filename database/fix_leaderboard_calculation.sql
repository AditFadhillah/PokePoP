-- Fix trainer_leaderboard view to calculate points from actual Pokemon inventory
-- This ensures the leaderboard always shows accurate points that match the inventory

DROP VIEW IF EXISTS public.trainer_leaderboard;

CREATE OR REPLACE VIEW public.trainer_leaderboard AS
SELECT 
    t.id,
    t.name,
    COALESCE(SUM(pi.points), 0) as total_points,  -- Calculate from actual Pokemon inventory
    t.created_at,
    COUNT(pi.id) as pokemon_count,
    t.user_id
FROM public.trainers t
LEFT JOIN public.pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.created_at, t.user_id
ORDER BY COALESCE(SUM(pi.points), 0) DESC, t.created_at ASC;

-- Grant necessary permissions
GRANT SELECT ON public.trainer_leaderboard TO authenticated;
GRANT SELECT ON public.trainer_leaderboard TO anon;

-- Test the view
SELECT * FROM public.trainer_leaderboard LIMIT 10;
