-- Backfill achievements for users who met the criteria but system was broken
-- This will check all users' stats and award achievements they should have earned

-- Call check_and_award_achievements for each user with stats
DO $$
DECLARE
    user_record RECORD;
BEGIN
    FOR user_record IN 
        SELECT DISTINCT user_id, trainer_id 
        FROM user_stats
    LOOP
        -- Award achievements based on current stats
        PERFORM check_and_award_achievements(
            user_record.user_id,
            user_record.trainer_id
        );
        
        RAISE NOTICE 'Processed achievements for user: %', user_record.user_id;
    END LOOP;
END $$;

-- Verify achievements were awarded
SELECT 
    u.username,
    t.name as trainer_name,
    COUNT(ua.id) as achievements_unlocked,
    COALESCE(SUM(a.points), 0) as total_achievement_points
FROM auth.users u
JOIN trainers t ON t.user_id = u.id
LEFT JOIN user_achievements ua ON ua.user_id = u.id
LEFT JOIN achievements a ON a.id = ua.achievement_id
WHERE u.username IN ('test5', 'test1', 'JuicyJulie', 'Usama', 'trainer1', 'trainer2', 'a')
GROUP BY u.username, t.name
ORDER BY achievements_unlocked DESC;
