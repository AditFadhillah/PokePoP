-- Quick check: What achievements does test1 have and what points should they have?

-- Check user achievements and their points
SELECT 
    t.name,
    a.title,
    a.category,
    a.points,
    ua.unlocked_at
FROM user_achievements ua
JOIN achievements a ON ua.achievement_id = a.id
JOIN trainers t ON ua.trainer_id = t.id
WHERE t.name = 'test1'
ORDER BY ua.unlocked_at;

-- Check total achievement points
SELECT 
    t.name,
    COUNT(ua.id) as total_achievements,
    SUM(a.points) as total_achievement_points,
    t.achievement_points as current_achievement_points,
    t.total_points as current_total_points
FROM trainers t
LEFT JOIN user_achievements ua ON t.id = ua.trainer_id
LEFT JOIN achievements a ON ua.achievement_id = a.id
WHERE t.name = 'test1'
GROUP BY t.id, t.name, t.achievement_points, t.total_points;
