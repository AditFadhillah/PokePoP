-- Sync user_stats duration fields with usage_sessions data
-- This calculates total_duration_minutes and longest_session_minutes from usage_sessions.active_ms

-- ============================================
-- PART 1: BACKFILL EXISTING DATA
-- ============================================

-- Update user_stats with calculated duration from usage_sessions
UPDATE user_stats us
SET 
    total_duration_minutes = (
        -- Sum all active_ms for this user and convert to minutes
        SELECT COALESCE(ROUND(SUM(active_ms) / 60000.0), 0)
        FROM usage_sessions
        WHERE username = (
            SELECT username 
            FROM test_username tu
            WHERE tu.id = us.user_id
        )
        AND ended_at IS NOT NULL  -- Only count completed sessions
    ),
    longest_session_minutes = (
        -- Get the longest active_ms for this user and convert to minutes
        SELECT COALESCE(ROUND(MAX(active_ms) / 60000.0), 0)
        FROM usage_sessions
        WHERE username = (
            SELECT username 
            FROM test_username tu
            WHERE tu.id = us.user_id
        )
        AND ended_at IS NOT NULL  -- Only count completed sessions
    ),
    updated_at = NOW()
WHERE EXISTS (
    SELECT 1 FROM test_username tu WHERE tu.id = us.user_id
);

-- ============================================
-- PART 2: CREATE TRIGGER TO AUTO-UPDATE
-- ============================================

-- Function to update user_stats when a session ends
CREATE OR REPLACE FUNCTION sync_user_stats_duration()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
    v_trainer_id UUID;
    v_total_duration_minutes INT;
    v_longest_session_minutes INT;
BEGIN
    -- Only process when a session ends (ended_at is set)
    IF NEW.ended_at IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Get user_id from test_username using username
    SELECT tu.id, t.id INTO v_user_id, v_trainer_id
    FROM test_username tu
    LEFT JOIN trainers t ON t.test_user_id = tu.id
    WHERE tu.username = NEW.username
    LIMIT 1;
    
    IF v_user_id IS NULL THEN
        -- User not found, skip update
        RETURN NEW;
    END IF;
    
    -- Calculate total duration in minutes (sum of all sessions)
    SELECT COALESCE(ROUND(SUM(active_ms) / 60000.0), 0)
    INTO v_total_duration_minutes
    FROM usage_sessions
    WHERE username = NEW.username
    AND ended_at IS NOT NULL;
    
    -- Calculate longest session in minutes
    SELECT COALESCE(ROUND(MAX(active_ms) / 60000.0), 0)
    INTO v_longest_session_minutes
    FROM usage_sessions
    WHERE username = NEW.username
    AND ended_at IS NOT NULL;
    
    -- Update user_stats
    UPDATE user_stats
    SET 
        total_duration_minutes = v_total_duration_minutes,
        longest_session_minutes = v_longest_session_minutes,
        updated_at = NOW()
    WHERE user_id = v_user_id;
    
    -- If user_stats doesn't exist yet, create it
    IF NOT FOUND AND v_trainer_id IS NOT NULL THEN
        INSERT INTO user_stats (
            user_id,
            trainer_id,
            total_duration_minutes,
            longest_session_minutes,
            total_captures,
            current_login_streak,
            longest_login_streak,
            last_login_date
        ) VALUES (
            v_user_id,
            v_trainer_id,
            v_total_duration_minutes,
            v_longest_session_minutes,
            0,
            1,
            1,
            CURRENT_DATE
        );
    END IF;
    
    -- Check for duration-based achievements
    IF v_trainer_id IS NOT NULL THEN
        PERFORM check_and_award_achievements(v_user_id, v_trainer_id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on usage_sessions
DROP TRIGGER IF EXISTS trigger_sync_duration_on_session_end ON usage_sessions;
CREATE TRIGGER trigger_sync_duration_on_session_end
AFTER INSERT OR UPDATE OF ended_at, active_ms ON usage_sessions
FOR EACH ROW
EXECUTE FUNCTION sync_user_stats_duration();

-- ============================================
-- PART 3: VERIFY THE UPDATE
-- ============================================

-- Show updated stats with session data
SELECT 
    '=== User Stats with Session Duration ===' as info,
    tu.username,
    us.total_captures,
    us.total_duration_minutes,
    us.longest_session_minutes,
    (
        SELECT COUNT(*) 
        FROM usage_sessions 
        WHERE username = tu.username 
        AND ended_at IS NOT NULL
    ) as completed_sessions,
    (
        SELECT ROUND(SUM(active_ms) / 60000.0) 
        FROM usage_sessions 
        WHERE username = tu.username 
        AND ended_at IS NOT NULL
    ) as calculated_total_minutes,
    (
        SELECT ROUND(MAX(active_ms) / 60000.0) 
        FROM usage_sessions 
        WHERE username = tu.username 
        AND ended_at IS NOT NULL
    ) as calculated_longest_minutes
FROM test_username tu
JOIN user_stats us ON us.user_id = tu.id
ORDER BY tu.username;

-- Check if any users qualify for duration achievements
SELECT 
    '=== Duration Achievement Eligibility ===' as info,
    tu.username,
    us.total_duration_minutes,
    CASE 
        WHEN us.total_duration_minutes >= 120 THEN '✓ Qualifies for duration_120 (Hardcore Player)'
        WHEN us.total_duration_minutes >= 90 THEN '✓ Qualifies for duration_90 (Dedicated Player)'
        WHEN us.total_duration_minutes >= 60 THEN '✓ Qualifies for duration_60 (Engaged Player)'
        ELSE '✗ No duration achievements yet (' || us.total_duration_minutes || ' min)'
    END as achievement_status,
    (
        SELECT COUNT(*) 
        FROM user_achievements ua
        JOIN achievements a ON a.id = ua.achievement_id
        WHERE ua.trainer_id = us.trainer_id
        AND a.category = 'duration'
    ) as duration_achievements_unlocked
FROM test_username tu
JOIN user_stats us ON us.user_id = tu.id
ORDER BY us.total_duration_minutes DESC;

SELECT '✅ User stats duration fields updated and trigger created!' as status;
SELECT '⏰ Duration will now auto-update when sessions end' as note;
