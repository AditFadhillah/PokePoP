-- Fix Region Achievement System to Track UNIQUE Pokemon Per Region
-- This replaces the simple counter with actual unique Pokemon tracking

-- Step 1: Create a table to define which Pokemon belong to which region
CREATE TABLE IF NOT EXISTS public.pokemon_regions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pokemon_name TEXT NOT NULL,
    region TEXT NOT NULL,
    is_rare BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(pokemon_name, region)
);

-- Step 2: Insert Pokemon region mappings (based on battle.gd)
INSERT INTO public.pokemon_regions (pokemon_name, region, is_rare) VALUES
-- Forest Region Pokemon
('RATTATA', 'Forest', FALSE),
('CATERPIE', 'Forest', FALSE),
('EEVEE', 'Forest', FALSE),
('VULPIX', 'Forest', FALSE),
('BULBASAUR', 'Forest', FALSE),
('PIDGEY', 'Forest', FALSE),

-- Beach Region Pokemon
('SQUIRTLE', 'Beach', FALSE),
('HORSEA', 'Beach', FALSE),
('MEOWTH', 'Beach', FALSE),
('KRABBY', 'Beach', FALSE),
('SEEL', 'Beach', FALSE),
('MAGIKARP', 'Beach', FALSE),

-- Volcano Region Pokemon
('CHARMANDER', 'Volcano', FALSE),
('DIGLETT', 'Volcano', FALSE),
('CUBONE', 'Volcano', FALSE),
('RHYHORN', 'Volcano', FALSE),
('PONYTA', 'Volcano', FALSE),
('GEODUDE', 'Volcano', FALSE),

-- Swamp Region Pokemon
('GRIMER', 'Swamp', FALSE),
('GASTLY', 'Swamp', FALSE),
('ODDISH', 'Swamp', FALSE),
('ZUBAT', 'Swamp', FALSE),
('VENONAT', 'Swamp', FALSE),
('EKANS', 'Swamp', FALSE),

-- Rare Pokemon (can appear in any region)
('VAPOREON', 'Any', TRUE),
('JOLTEON', 'Any', TRUE),
('FLAREON', 'Any', TRUE),
('DITTO', 'Any', TRUE),
('MEW', 'Any', TRUE),
('PIKACHU_', 'Any', TRUE)
ON CONFLICT (pokemon_name, region) DO NOTHING;

-- Step 3: Create a function to get unique Pokemon count per region for a trainer
CREATE OR REPLACE FUNCTION get_unique_pokemon_by_region(p_trainer_id UUID)
RETURNS TABLE (
    region TEXT,
    unique_count BIGINT,
    pokemon_list TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pr.region,
        COUNT(DISTINCT pi.pokemon_name) AS unique_count,
        ARRAY_AGG(DISTINCT pi.pokemon_name ORDER BY pi.pokemon_name) AS pokemon_list
    FROM public.pokemon_inventory pi
    JOIN public.pokemon_regions pr ON pi.pokemon_name = pr.pokemon_name
    WHERE pi.trainer_id = p_trainer_id
      AND pr.is_rare = FALSE  -- Exclude rare Pokemon from region completion
    GROUP BY pr.region;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 4: Update check_and_award_achievements to use unique Pokemon counts
DROP FUNCTION IF EXISTS check_and_award_achievements(UUID, UUID);

CREATE OR REPLACE FUNCTION check_and_award_achievements(
    p_user_id UUID,
    p_trainer_id UUID
)
RETURNS TABLE (
    newly_unlocked_achievement_id UUID,
    achievement_title TEXT,
    achievement_description TEXT,
    achievement_icon TEXT,
    achievement_points INTEGER
) AS $$
DECLARE
    user_stat RECORD;
    achievement RECORD;
    forest_unique INTEGER := 0;
    beach_unique INTEGER := 0;
    volcano_unique INTEGER := 0;
    swamp_unique INTEGER := 0;
BEGIN
    -- Get current user stats
    SELECT * INTO user_stat FROM public.user_stats WHERE user_id = p_user_id;
    
    IF user_stat IS NULL THEN
        RETURN;
    END IF;
    
    -- Get unique Pokemon counts per region
    SELECT unique_count INTO forest_unique 
    FROM get_unique_pokemon_by_region(p_trainer_id) 
    WHERE region = 'Forest';
    
    SELECT unique_count INTO beach_unique 
    FROM get_unique_pokemon_by_region(p_trainer_id) 
    WHERE region = 'Beach';
    
    SELECT unique_count INTO volcano_unique 
    FROM get_unique_pokemon_by_region(p_trainer_id) 
    WHERE region = 'Volcano';
    
    SELECT unique_count INTO swamp_unique 
    FROM get_unique_pokemon_by_region(p_trainer_id) 
    WHERE region = 'Swamp';
    
    -- Set to 0 if NULL
    forest_unique := COALESCE(forest_unique, 0);
    beach_unique := COALESCE(beach_unique, 0);
    volcano_unique := COALESCE(volcano_unique, 0);
    swamp_unique := COALESCE(swamp_unique, 0);
    
    -- Check each achievement category
    FOR achievement IN 
        SELECT a.* FROM public.achievements a
        WHERE a.id NOT IN (
            SELECT achievement_id FROM public.user_achievements 
            WHERE user_id = p_user_id
        )
    LOOP
        -- Check if achievement should be awarded
        IF (achievement.category = 'first_capture' AND user_stat.total_captures >= achievement.requirement_value) OR
           (achievement.category = 'login_streak' AND user_stat.current_login_streak >= achievement.requirement_value) OR
           (achievement.category = 'total_captures' AND user_stat.total_captures >= achievement.requirement_value) OR
           (achievement.category = 'duration' AND user_stat.total_duration_minutes >= achievement.requirement_value) OR
           (achievement.category = 'region_complete' AND 
               ((achievement.achievement_key = 'forest_complete' AND forest_unique >= 6) OR
                (achievement.achievement_key = 'beach_complete' AND beach_unique >= 6) OR
                (achievement.achievement_key = 'volcano_complete' AND volcano_unique >= 6) OR
                (achievement.achievement_key = 'swamp_complete' AND swamp_unique >= 6))
           )
        THEN
            -- Award the achievement
            INSERT INTO public.user_achievements (user_id, trainer_id, achievement_id)
            VALUES (p_user_id, p_trainer_id, achievement.id)
            ON CONFLICT (user_id, achievement_id) DO NOTHING;
            
            -- Return newly unlocked achievement
            RETURN QUERY 
            SELECT 
                achievement.id,
                achievement.title,
                achievement.description,
                achievement.icon,
                achievement.points;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Create a view to show region completion progress for all trainers
CREATE OR REPLACE VIEW public.trainer_region_progress AS
SELECT 
    t.id AS trainer_id,
    t.name AS trainer_name,
    t.user_id,
    COALESCE(forest.unique_count, 0) AS forest_unique,
    COALESCE(forest.pokemon_list, ARRAY[]::TEXT[]) AS forest_pokemon,
    CASE WHEN COALESCE(forest.unique_count, 0) >= 6 THEN TRUE ELSE FALSE END AS forest_complete,
    
    COALESCE(beach.unique_count, 0) AS beach_unique,
    COALESCE(beach.pokemon_list, ARRAY[]::TEXT[]) AS beach_pokemon,
    CASE WHEN COALESCE(beach.unique_count, 0) >= 6 THEN TRUE ELSE FALSE END AS beach_complete,
    
    COALESCE(volcano.unique_count, 0) AS volcano_unique,
    COALESCE(volcano.pokemon_list, ARRAY[]::TEXT[]) AS volcano_pokemon,
    CASE WHEN COALESCE(volcano.unique_count, 0) >= 6 THEN TRUE ELSE FALSE END AS volcano_complete,
    
    COALESCE(swamp.unique_count, 0) AS swamp_unique,
    COALESCE(swamp.pokemon_list, ARRAY[]::TEXT[]) AS swamp_pokemon,
    CASE WHEN COALESCE(swamp.unique_count, 0) >= 6 THEN TRUE ELSE FALSE END AS swamp_complete
FROM public.trainers t
LEFT JOIN get_unique_pokemon_by_region(t.id) forest ON forest.region = 'Forest'
LEFT JOIN get_unique_pokemon_by_region(t.id) beach ON beach.region = 'Beach'
LEFT JOIN get_unique_pokemon_by_region(t.id) volcano ON volcano.region = 'Volcano'
LEFT JOIN get_unique_pokemon_by_region(t.id) swamp ON swamp.region = 'Swamp';

-- Step 6: Update the points as before
UPDATE public.achievements
SET points = CASE 
    WHEN achievement_key = 'capture_5' THEN 100
    WHEN achievement_key = 'capture_10' THEN 200
    WHEN achievement_key = 'capture_15' THEN 300
    WHEN achievement_key = 'capture_20' THEN 400
    WHEN achievement_key = 'forest_complete' THEN 500
    WHEN achievement_key = 'beach_complete' THEN 500
    WHEN achievement_key = 'volcano_complete' THEN 500
    WHEN achievement_key = 'swamp_complete' THEN 500
    ELSE points
END
WHERE points = 0;

-- Step 7: Re-award achievements based on NEW unique Pokemon logic
DO $$
DECLARE
    user_rec RECORD;
    trainer_rec RECORD;
BEGIN
    -- Loop through all trainers
    FOR trainer_rec IN 
        SELECT t.id, t.user_id FROM public.trainers t WHERE t.user_id IS NOT NULL
    LOOP
        -- Call the updated check function
        PERFORM check_and_award_achievements(trainer_rec.user_id, trainer_rec.id);
    END LOOP;
END $$;

-- Step 8: Verification - Show region progress for test1
SELECT 
    'Region Progress for test1' AS info,
    trainer_name,
    forest_unique || '/6' AS forest_progress,
    forest_pokemon,
    forest_complete,
    beach_unique || '/6' AS beach_progress,
    beach_pokemon,
    beach_complete,
    volcano_unique || '/6' AS volcano_progress,
    volcano_pokemon,
    volcano_complete,
    swamp_unique || '/6' AS swamp_progress,
    swamp_pokemon,
    swamp_complete
FROM public.trainer_region_progress
WHERE trainer_id = 'f362f578-c144-4f1a-8142-8840b206e8c8';

-- Step 9: Show achievements for test1
SELECT 
    'Achievements for test1' AS info,
    a.achievement_key,
    a.title,
    a.category,
    a.points,
    ua.unlocked_at
FROM public.user_achievements ua
JOIN public.achievements a ON ua.achievement_id = a.id
WHERE ua.trainer_id = 'f362f578-c144-4f1a-8142-8840b206e8c8'
ORDER BY a.category, ua.unlocked_at;

-- Step 10: Show which specific Pokemon test1 needs for each region
SELECT 
    'Missing Pokemon for test1' AS info,
    pr.region,
    pr.pokemon_name,
    CASE 
        WHEN pi.id IS NOT NULL THEN '✓ Captured'
        ELSE '✗ Not captured yet'
    END AS status
FROM public.pokemon_regions pr
LEFT JOIN public.pokemon_inventory pi ON 
    pr.pokemon_name = pi.pokemon_name 
    AND pi.trainer_id = 'f362f578-c144-4f1a-8142-8840b206e8c8'
WHERE pr.is_rare = FALSE
ORDER BY pr.region, pr.pokemon_name;

SELECT 'Region Achievement System Updated with Unique Pokemon Tracking!' AS status;
