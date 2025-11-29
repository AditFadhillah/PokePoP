-- Fix Achievement Points and Region Complete Detection
-- This script fixes two issues:
-- 1. Updates all achievements with 0 points to have at least 100 points
-- 2. Manually triggers achievement check for users who should have region_complete achievements

-- Step 1: Update achievement points (set minimum to 100)
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

-- Step 2: Check current user stats to see who should have region achievements
SELECT 
    us.user_id,
    us.trainer_id,
    us.forest_captures,
    us.beach_captures,
    us.volcano_captures,
    us.swamp_captures,
    t.name as trainer_name
FROM public.user_stats us
JOIN public.trainers t ON us.trainer_id = t.id
WHERE us.forest_captures >= 6 
   OR us.beach_captures >= 6 
   OR us.volcano_captures >= 6 
   OR us.swamp_captures >= 6;

-- Step 3: Manually award missing region achievements
DO $$
DECLARE
    user_rec RECORD;
    achievement_rec RECORD;
BEGIN
    -- Loop through all users with stats
    FOR user_rec IN 
        SELECT user_id, trainer_id, forest_captures, beach_captures, volcano_captures, swamp_captures
        FROM public.user_stats
    LOOP
        -- Check Forest Complete
        IF user_rec.forest_captures >= 6 THEN
            SELECT id INTO achievement_rec FROM public.achievements WHERE achievement_key = 'forest_complete';
            IF FOUND THEN
                INSERT INTO public.user_achievements (user_id, trainer_id, achievement_id)
                VALUES (user_rec.user_id, user_rec.trainer_id, achievement_rec.id)
                ON CONFLICT (user_id, achievement_id) DO NOTHING;
            END IF;
        END IF;
        
        -- Check Beach Complete
        IF user_rec.beach_captures >= 6 THEN
            SELECT id INTO achievement_rec FROM public.achievements WHERE achievement_key = 'beach_complete';
            IF FOUND THEN
                INSERT INTO public.user_achievements (user_id, trainer_id, achievement_id)
                VALUES (user_rec.user_id, user_rec.trainer_id, achievement_rec.id)
                ON CONFLICT (user_id, achievement_id) DO NOTHING;
            END IF;
        END IF;
        
        -- Check Volcano Complete
        IF user_rec.volcano_captures >= 6 THEN
            SELECT id INTO achievement_rec FROM public.achievements WHERE achievement_key = 'volcano_complete';
            IF FOUND THEN
                INSERT INTO public.user_achievements (user_id, trainer_id, achievement_id)
                VALUES (user_rec.user_id, user_rec.trainer_id, achievement_rec.id)
                ON CONFLICT (user_id, achievement_id) DO NOTHING;
            END IF;
        END IF;
        
        -- Check Swamp Complete
        IF user_rec.swamp_captures >= 6 THEN
            SELECT id INTO achievement_rec FROM public.achievements WHERE achievement_key = 'swamp_complete';
            IF FOUND THEN
                INSERT INTO public.user_achievements (user_id, trainer_id, achievement_id)
                VALUES (user_rec.user_id, user_rec.trainer_id, achievement_rec.id)
                ON CONFLICT (user_id, achievement_id) DO NOTHING;
            END IF;
        END IF;
    END LOOP;
END $$;

-- Step 4: Verify the fixes
SELECT 'Achievement Points Updated!' as status;

SELECT achievement_key, title, points 
FROM public.achievements 
WHERE category IN ('total_captures', 'region_complete')
ORDER BY achievement_key;

-- Step 5: Show newly awarded achievements for test1 user
SELECT 
    t.name as trainer_name,
    a.achievement_key,
    a.title,
    a.points,
    ua.unlocked_at
FROM public.user_achievements ua
JOIN public.achievements a ON ua.achievement_id = a.id
JOIN public.trainers t ON ua.trainer_id = t.id
WHERE ua.trainer_id = 'f362f578-c144-4f1a-8142-8840b206e8c8'
ORDER BY ua.unlocked_at DESC;

-- Step 6: Show total points for test1
SELECT 
    t.name as trainer_name,
    tl.total_points as total_points_with_achievements
FROM public.trainer_leaderboard tl
JOIN public.trainers t ON tl.id = t.id
WHERE t.id = 'f362f578-c144-4f1a-8142-8840b206e8c8';
