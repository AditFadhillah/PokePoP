-- Fix ambiguous column reference in check_and_award_achievements function

DROP FUNCTION IF EXISTS check_and_award_achievements(UUID, UUID);

CREATE OR REPLACE FUNCTION check_and_award_achievements(
    p_user_id UUID,
    p_trainer_id UUID
)
RETURNS TABLE (
    unlocked_achievement_id UUID,
    achievement_key TEXT,
    title TEXT,
    description TEXT,
    icon TEXT,
    points INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_achievement_points INTEGER := 0;
    v_unlocked_ids UUID[];
BEGIN
    -- Find and insert eligible achievements, capture the IDs
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
        SELECT p_user_id, p_trainer_id, ea.id
        FROM eligible_achievements ea
        RETURNING achievement_id
    )
    SELECT ARRAY_AGG(achievement_id) INTO v_unlocked_ids FROM newly_unlocked;
    
    -- Calculate total achievement points
    SELECT COALESCE(SUM(a.points), 0) INTO v_total_achievement_points
    FROM achievements a
    WHERE a.id = ANY(v_unlocked_ids);
    
    -- Return the unlocked achievements
    RETURN QUERY
    SELECT 
        a.id as unlocked_achievement_id,
        a.achievement_key,
        a.title,
        a.description,
        a.icon,
        a.points
    FROM achievements a
    WHERE a.id = ANY(v_unlocked_ids);
    
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

-- Verify the fix
SELECT 'check_and_award_achievements function updated with fix for ambiguous column!' as status;
