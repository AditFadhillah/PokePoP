-- Sync trainer total_points with actual Pokemon inventory sum
-- This updates the trainers.total_points column to match the real sum

UPDATE public.trainers t
SET total_points = COALESCE(
    (SELECT SUM(pi.points) 
     FROM public.pokemon_inventory pi 
     WHERE pi.trainer_id = t.id),
    0
),
updated_at = NOW();

-- Show the results
SELECT 
    t.id,
    t.name,
    t.total_points as new_total_points,
    COALESCE(SUM(pi.points), 0) as calculated_from_inventory,
    COUNT(pi.id) as pokemon_count
FROM public.trainers t
LEFT JOIN public.pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.total_points
ORDER BY t.total_points DESC;
