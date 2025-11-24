-- Backfill achievement_points for users who unlocked achievements before the points system was added

-- Step 1: Check what points each achievement has
SELECT 
    id,
    achievement_key,
    title,
    points
FROM achievements
ORDER BY achievement_key;

-- Step 2: Calculate and update achievement_points for all trainers based on their unlocked achievements
UPDATE trainers t
SET achievement_points = COALESCE(
    (
        SELECT SUM(a.points)
        FROM user_achievements ua
        JOIN achievements a ON ua.achievement_id = a.id
        WHERE ua.trainer_id = t.id
    ),
    0
);

-- Step 3: Now update total_points to include achievement_points
UPDATE trainers t
SET total_points = COALESCE(
    (SELECT SUM(pi.points) FROM pokemon_inventory pi WHERE pi.trainer_id = t.id),
    0
) + COALESCE(t.achievement_points, 0);

-- Step 4: Verify the results
SELECT 
    t.name,
    t.user_id,
    COUNT(ua.id) as achievements_unlocked,
    COALESCE(SUM(a.points), 0) as calculated_achievement_points,
    t.achievement_points as stored_achievement_points,
    COALESCE(SUM(pi.points), 0) as pokemon_points,
    t.total_points,
    CASE 
        WHEN t.achievement_points = COALESCE(SUM(a.points), 0)
        THEN '✓ Achievement points correct'
        ELSE '✗ Achievement points mismatch'
    END as achievement_status,
    CASE 
        WHEN t.total_points = (COALESCE(SUM(pi.points), 0) + t.achievement_points)
        THEN '✓ Total points correct'
        ELSE '✗ Total points mismatch'
    END as total_status
FROM trainers t
LEFT JOIN pokemon_inventory pi ON t.id = pi.trainer_id
LEFT JOIN user_achievements ua ON t.id = ua.trainer_id
LEFT JOIN achievements a ON ua.achievement_id = a.id
GROUP BY t.id, t.name, t.user_id, t.achievement_points, t.total_points
ORDER BY t.name;

-- Step 5: Show detailed breakdown for test1
SELECT 
    t.name,
    a.title as achievement_title,
    a.points as achievement_points,
    ua.unlocked_at
FROM user_achievements ua
JOIN achievements a ON ua.achievement_id = a.id
JOIN trainers t ON ua.trainer_id = t.id
WHERE t.name = 'test1'
ORDER BY ua.unlocked_at;
