-- Fix the sync_trainer_total_points() trigger function to work correctly
-- The problem: It tries to reference NEW.trainer_id even when triggered from trainers table

DROP FUNCTION IF EXISTS sync_trainer_total_points() CASCADE;

CREATE OR REPLACE FUNCTION sync_trainer_total_points()
RETURNS TRIGGER AS $$
DECLARE
    v_trainer_id UUID;
BEGIN
    -- Determine the trainer_id based on which table triggered this
    IF TG_TABLE_NAME = 'pokemon_inventory' THEN
        -- Triggered from pokemon_inventory - use trainer_id field
        v_trainer_id := COALESCE(NEW.trainer_id, OLD.trainer_id);
    ELSIF TG_TABLE_NAME = 'trainers' THEN
        -- Triggered from trainers table - use id field
        v_trainer_id := COALESCE(NEW.id, OLD.id);
    ELSIF TG_TABLE_NAME = 'user_achievements' THEN
        -- Triggered from user_achievements - use trainer_id field
        v_trainer_id := COALESCE(NEW.trainer_id, OLD.trainer_id);
    ELSE
        -- Unknown table, try both
        v_trainer_id := COALESCE(NEW.trainer_id, OLD.trainer_id, NEW.id, OLD.id);
    END IF;
    
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
    WHERE id = v_trainer_id;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Recreate the triggers
DROP TRIGGER IF EXISTS trigger_sync_total_points_on_pokemon ON pokemon_inventory;
CREATE TRIGGER trigger_sync_total_points_on_pokemon
AFTER INSERT OR UPDATE OR DELETE ON pokemon_inventory
FOR EACH ROW
EXECUTE FUNCTION sync_trainer_total_points();

DROP TRIGGER IF EXISTS trigger_sync_total_points_on_achievement_points ON trainers;
CREATE TRIGGER trigger_sync_total_points_on_achievement_points
AFTER UPDATE OF achievement_points ON trainers
FOR EACH ROW
WHEN (OLD.achievement_points IS DISTINCT FROM NEW.achievement_points)
EXECUTE FUNCTION sync_trainer_total_points();

SELECT '✅ Fixed sync_trainer_total_points() trigger function!' as status;
