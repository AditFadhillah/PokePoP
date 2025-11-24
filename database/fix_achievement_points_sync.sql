-- Fix: Automatically sync total_points when achievement_points changes

-- Step 1: Create a trigger function that updates total_points whenever achievement_points changes
CREATE OR REPLACE FUNCTION sync_trainer_total_points_on_achievement()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- When achievement_points changes, recalculate total_points
    NEW.total_points = COALESCE(
        (SELECT SUM(pi.points) FROM pokemon_inventory pi WHERE pi.trainer_id = NEW.id),
        0
    ) + COALESCE(NEW.achievement_points, 0);
    
    RETURN NEW;
END;
$$;

-- Step 2: Drop the trigger if it exists
DROP TRIGGER IF EXISTS trigger_sync_total_points_on_achievement ON trainers;

-- Step 3: Create the trigger
CREATE TRIGGER trigger_sync_total_points_on_achievement
    BEFORE UPDATE OF achievement_points ON trainers
    FOR EACH ROW
    WHEN (OLD.achievement_points IS DISTINCT FROM NEW.achievement_points)
    EXECUTE FUNCTION sync_trainer_total_points_on_achievement();

-- Step 4: Also update the check_and_award_achievements function to ensure total_points is updated
DROP FUNCTION IF EXISTS check_and_award_achievements(UUID, UUID);

CREATE OR REPLACE FUNCTION check_and_award_achievements(
    p_user_id UUID,
    p_trainer_id UUID
)
RETURNS TABLE (
    achievement_id UUID,
    achievement_key TEXT,
    title TEXT,
    description TEXT,
    icon TEXT,
    points INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_achievement_points INTEGER;
BEGIN
    RETURN QUERY
    WITH stats AS (
        SELECT * FROM user_stats WHERE user_id = p_user_id
    ),
    eligible_achievements AS (
        SELECT a.*
        FROM achievements a
        LEFT JOIN user_achievements ua ON 
            ua.achievement_id = a.id AND 
            ua.user_id = p_user_id
        CROSS JOIN stats s
        WHERE ua.id IS NULL  -- Not yet unlocked
        AND (
            -- First capture
            (a.category = 'first_capture' AND s.total_captures >= 1)
            OR
            -- Login streaks
            (a.category = 'login_streak' AND s.current_login_streak >= a.requirement_value)
            OR
            -- Total captures
            (a.category = 'total_captures' AND s.total_captures >= a.requirement_value)
            OR
            -- Region complete (all Pokemon in region)
            (a.category = 'region_complete' AND (
                (a.achievement_key = 'region_forest_complete' AND s.forest_captures >= a.requirement_value) OR
                (a.achievement_key = 'region_beach_complete' AND s.beach_captures >= a.requirement_value) OR
                (a.achievement_key = 'region_volcano_complete' AND s.volcano_captures >= a.requirement_value) OR
                (a.achievement_key = 'region_swamp_complete' AND s.swamp_captures >= a.requirement_value)
            ))
            OR
            -- Duration achievements
            (a.category = 'duration' AND s.total_duration_minutes >= a.requirement_value)
        )
    ),
    newly_unlocked AS (
        INSERT INTO user_achievements (user_id, trainer_id, achievement_id)
        SELECT p_user_id, p_trainer_id, a.id
        FROM eligible_achievements a
        RETURNING achievement_id
    )
    SELECT 
        a.id as achievement_id,
        a.achievement_key,
        a.title,
        a.description,
        a.icon,
        a.points
    FROM newly_unlocked nu
    JOIN achievements a ON a.id = nu.achievement_id;
    
    -- Calculate total achievement points to add
    SELECT COALESCE(SUM(a.points), 0) INTO v_total_achievement_points
    FROM newly_unlocked nu
    JOIN achievements a ON a.id = nu.achievement_id;
    
    -- Award points for each newly unlocked achievement AND update total_points
    UPDATE trainers t
    SET 
        achievement_points = achievement_points + v_total_achievement_points,
        total_points = COALESCE(
            (SELECT SUM(pi.points) FROM pokemon_inventory pi WHERE pi.trainer_id = t.id),
            0
        ) + achievement_points + v_total_achievement_points,
        updated_at = NOW()
    WHERE t.id = p_trainer_id;
END;
$$;

-- Step 5: Run a one-time sync to fix existing data
UPDATE trainers t
SET total_points = COALESCE(
    (SELECT SUM(pi.points) FROM pokemon_inventory pi WHERE pi.trainer_id = t.id),
    0
) + COALESCE(t.achievement_points, 0),
updated_at = NOW();

-- Step 6: Verify the fix
SELECT 
    t.name,
    COALESCE(SUM(pi.points), 0) as pokemon_points,
    t.achievement_points,
    t.total_points,
    (COALESCE(SUM(pi.points), 0) + COALESCE(t.achievement_points, 0)) as calculated_total,
    CASE 
        WHEN t.total_points = (COALESCE(SUM(pi.points), 0) + COALESCE(t.achievement_points, 0))
        THEN '✓ Correct'
        ELSE '✗ Mismatch'
    END as status
FROM trainers t
LEFT JOIN pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.achievement_points, t.total_points
ORDER BY t.total_points DESC;
