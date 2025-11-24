-- Update get_user_achievements function to include points

DROP FUNCTION IF EXISTS get_user_achievements(UUID);

CREATE OR REPLACE FUNCTION get_user_achievements(p_user_id UUID)
RETURNS TABLE (
    achievement_id UUID,
    achievement_key TEXT,
    title TEXT,
    description TEXT,
    category TEXT,
    icon TEXT,
    unlocked_at TIMESTAMP WITH TIME ZONE,
    points INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.achievement_key,
        a.title,
        a.description,
        a.category,
        a.icon,
        ua.unlocked_at,
        a.points
    FROM public.user_achievements ua
    JOIN public.achievements a ON ua.achievement_id = a.id
    WHERE ua.user_id = p_user_id
    ORDER BY ua.unlocked_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Verify it works
SELECT 'get_user_achievements function updated to include points!' as status;
