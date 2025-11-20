-- Fix the double-counting issue for all trainers
-- This recalculates total_points from actual Pokemon inventory

UPDATE public.trainers t
SET total_points = COALESCE(
    (SELECT SUM(pi.points) 
     FROM public.pokemon_inventory pi 
     WHERE pi.trainer_id = t.id),
    0
),
updated_at = NOW();

-- Verify the fix
SELECT 
    t.name,
    t.total_points as trainers_table_points,
    COALESCE(SUM(pi.points), 0) as pokemon_inventory_sum,
    COUNT(pi.id) as pokemon_count
FROM public.trainers t
LEFT JOIN public.pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.total_points
ORDER BY t.total_points DESC;
