-- Create a function to recalculate and update trainer total_points
CREATE OR REPLACE FUNCTION update_trainer_total_points()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the trainer's total_points based on sum of their Pokemon inventory
    UPDATE public.trainers
    SET total_points = COALESCE(
        (SELECT SUM(points) 
         FROM public.pokemon_inventory 
         WHERE trainer_id = COALESCE(NEW.trainer_id, OLD.trainer_id)),
        0
    ),
    updated_at = NOW()
    WHERE id = COALESCE(NEW.trainer_id, OLD.trainer_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS sync_trainer_points_on_insert ON public.pokemon_inventory;
DROP TRIGGER IF EXISTS sync_trainer_points_on_update ON public.pokemon_inventory;
DROP TRIGGER IF EXISTS sync_trainer_points_on_delete ON public.pokemon_inventory;

-- Trigger when a new Pokemon is captured (INSERT)
CREATE TRIGGER sync_trainer_points_on_insert
    AFTER INSERT ON public.pokemon_inventory
    FOR EACH ROW
    EXECUTE FUNCTION update_trainer_total_points();

-- Trigger when Pokemon points are updated (UPDATE)
CREATE TRIGGER sync_trainer_points_on_update
    AFTER UPDATE ON public.pokemon_inventory
    FOR EACH ROW
    EXECUTE FUNCTION update_trainer_total_points();

-- Trigger when a Pokemon is deleted (DELETE)
CREATE TRIGGER sync_trainer_points_on_delete
    AFTER DELETE ON public.pokemon_inventory
    FOR EACH ROW
    EXECUTE FUNCTION update_trainer_total_points();

-- Now sync existing data to fix current discrepancies
UPDATE public.trainers t
SET total_points = COALESCE(
    (SELECT SUM(pi.points) 
     FROM public.pokemon_inventory pi 
     WHERE pi.trainer_id = t.id),
    0
),
updated_at = NOW();

-- Verify the results match between trainers table and leaderboard view
SELECT 
    t.id,
    t.name,
    t.total_points as trainers_table_points,
    COALESCE(SUM(pi.points), 0) as inventory_calculated_points,
    t.total_points - COALESCE(SUM(pi.points), 0) as difference,
    COUNT(pi.id) as pokemon_count
FROM public.trainers t
LEFT JOIN public.pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.total_points
ORDER BY t.total_points DESC;

-- Show the leaderboard to confirm it matches
SELECT * FROM public.trainer_leaderboard ORDER BY total_points DESC;
