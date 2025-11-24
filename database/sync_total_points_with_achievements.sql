-- Sync total_points in trainers table to include achievement_points
-- This makes trainers.total_points = pokemon_points + achievement_points

-- Step 1: Update existing trainers to include achievement_points in total_points
UPDATE trainers
SET total_points = (
    -- Calculate pokemon points
    COALESCE((
        SELECT SUM(points)
        FROM pokemon_inventory
        WHERE trainer_id = trainers.id
    ), 0)
    -- Add achievement points
    + COALESCE(achievement_points, 0)
);

-- Step 2: Drop existing function and create new one to sync total_points
DROP FUNCTION IF EXISTS sync_trainer_total_points() CASCADE;

CREATE FUNCTION sync_trainer_total_points()
RETURNS TRIGGER AS $$
BEGIN
    -- Recalculate total_points for the affected trainer
    UPDATE trainers
    SET total_points = (
        -- Calculate pokemon points
        COALESCE((
            SELECT SUM(points)
            FROM pokemon_inventory
            WHERE trainer_id = trainers.id
        ), 0)
        -- Add achievement points
        + COALESCE(achievement_points, 0)
    )
    WHERE id = COALESCE(NEW.trainer_id, OLD.trainer_id, NEW.id, OLD.id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Step 3: Create trigger on pokemon_inventory changes
DROP TRIGGER IF EXISTS trigger_sync_total_points_on_pokemon ON pokemon_inventory;
CREATE TRIGGER trigger_sync_total_points_on_pokemon
AFTER INSERT OR UPDATE OR DELETE ON pokemon_inventory
FOR EACH ROW
EXECUTE FUNCTION sync_trainer_total_points();

-- Step 4: Create trigger on trainers.achievement_points changes
DROP TRIGGER IF EXISTS trigger_sync_total_points_on_achievement_points ON trainers;
CREATE TRIGGER trigger_sync_total_points_on_achievement_points
AFTER UPDATE OF achievement_points ON trainers
FOR EACH ROW
WHEN (OLD.achievement_points IS DISTINCT FROM NEW.achievement_points)
EXECUTE FUNCTION sync_trainer_total_points();

-- Verify the update
SELECT 
    id,
    name,
    total_points,
    achievement_points,
    (SELECT COALESCE(SUM(points), 0) FROM pokemon_inventory WHERE trainer_id = trainers.id) as pokemon_points
FROM trainers
WHERE name = 'test1';
