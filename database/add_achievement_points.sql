-- Add Achievement Bonus Points System
-- This adds a separate tracking system for achievement points that gets added to Pokemon capture points

-- Step 1: Add achievement_points column to trainers table
ALTER TABLE public.trainers 
ADD COLUMN IF NOT EXISTS achievement_points INTEGER DEFAULT 0;

-- Step 2: Add points value to achievements table
ALTER TABLE public.achievements
ADD COLUMN IF NOT EXISTS points INTEGER DEFAULT 0;

-- Step 3: Set point values for each achievement
UPDATE public.achievements SET points = 100 WHERE achievement_key = 'first_capture';
UPDATE public.achievements SET points = 50 WHERE achievement_key = 'login_streak_1';
UPDATE public.achievements SET points = 75 WHERE achievement_key = 'login_streak_2';
UPDATE public.achievements SET points = 100 WHERE achievement_key = 'login_streak_3';
UPDATE public.achievements SET points = 150 WHERE achievement_key = 'login_streak_4';
UPDATE public.achievements SET points = 200 WHERE achievement_key = 'login_streak_5';
UPDATE public.achievements SET points = 150 WHERE achievement_key = 'total_captures_5';
UPDATE public.achievements SET points = 300 WHERE achievement_key = 'total_captures_10';
UPDATE public.achievements SET points = 500 WHERE achievement_key = 'total_captures_15';
UPDATE public.achievements SET points = 750 WHERE achievement_key = 'total_captures_20';
UPDATE public.achievements SET points = 400 WHERE achievement_key = 'region_forest_complete';
UPDATE public.achievements SET points = 400 WHERE achievement_key = 'region_beach_complete';
UPDATE public.achievements SET points = 400 WHERE achievement_key = 'region_volcano_complete';
UPDATE public.achievements SET points = 400 WHERE achievement_key = 'region_swamp_complete';
UPDATE public.achievements SET points = 250 WHERE achievement_key = 'duration_60';
UPDATE public.achievements SET points = 500 WHERE achievement_key = 'duration_90';
UPDATE public.achievements SET points = 1000 WHERE achievement_key = 'duration_120';

-- Step 4: Create function to award achievement points to trainer
CREATE OR REPLACE FUNCTION award_achievement_points(
    p_user_id UUID,
    p_trainer_id UUID,
    p_achievement_id UUID
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_points INTEGER;
BEGIN
    -- Get the point value for this achievement
    SELECT points INTO v_points
    FROM achievements
    WHERE id = p_achievement_id;
    
    -- Add points to trainer's achievement_points
    UPDATE trainers
    SET achievement_points = achievement_points + COALESCE(v_points, 0),
        updated_at = NOW()
    WHERE id = p_trainer_id;
    
    -- Log for debugging
    RAISE NOTICE 'Awarded % achievement points to trainer %', v_points, p_trainer_id;
END;
$$;

-- Step 5: Drop the old function first to allow return type change
DROP FUNCTION IF EXISTS check_and_award_achievements(UUID, UUID);

-- Step 5: Update the check_and_award_achievements function to also award points
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
    
    -- Award points for each newly unlocked achievement
    UPDATE trainers t
    SET achievement_points = achievement_points + COALESCE(
        (SELECT SUM(a.points)
         FROM newly_unlocked nu
         JOIN achievements a ON a.id = nu.achievement_id),
        0
    ),
    updated_at = NOW()
    WHERE t.id = p_trainer_id;
END;
$$;

-- Step 6: Drop the old view first to allow structure change
DROP VIEW IF EXISTS trainer_leaderboard;

-- Step 6: Create or update leaderboard view to include achievement points
CREATE OR REPLACE VIEW trainer_leaderboard AS
SELECT 
    t.id,
    t.name,
    t.user_id,
    COALESCE(SUM(pi.points), 0) as pokemon_points,
    t.achievement_points,
    (COALESCE(SUM(pi.points), 0) + COALESCE(t.achievement_points, 0)) as total_points,
    COUNT(pi.id) as pokemon_count,
    t.created_at,
    t.updated_at
FROM public.trainers t
LEFT JOIN public.pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.user_id, t.achievement_points, t.created_at, t.updated_at
ORDER BY total_points DESC;

-- Step 7: Update the total_points column in trainers to be computed correctly
-- (This keeps backward compatibility)
CREATE OR REPLACE FUNCTION sync_trainer_total_points()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE trainers t
    SET total_points = COALESCE(
        (SELECT SUM(pi.points) FROM pokemon_inventory pi WHERE pi.trainer_id = t.id),
        0
    ) + COALESCE(t.achievement_points, 0),
    updated_at = NOW();
END;
$$;

-- Run initial sync
SELECT sync_trainer_total_points();

-- Step 8: Show current status
SELECT 
    t.name,
    COALESCE(SUM(pi.points), 0) as pokemon_points,
    t.achievement_points,
    t.total_points,
    COUNT(ua.id) as achievements_unlocked
FROM trainers t
LEFT JOIN pokemon_inventory pi ON t.id = pi.trainer_id
LEFT JOIN user_achievements ua ON t.id = ua.trainer_id
GROUP BY t.id, t.name, t.achievement_points, t.total_points
ORDER BY t.total_points DESC;

-- Verification query - show point breakdown
SELECT 
    a.title,
    a.category,
    a.points,
    COUNT(ua.id) as times_unlocked,
    (a.points * COUNT(ua.id)) as total_points_awarded
FROM achievements a
LEFT JOIN user_achievements ua ON a.id = ua.achievement_id
GROUP BY a.id, a.title, a.category, a.points
ORDER BY total_points_awarded DESC;
