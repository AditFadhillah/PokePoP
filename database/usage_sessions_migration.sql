-- Usage Sessions Table Migration
-- Run this in your Supabase SQL Editor to add usage tracking

-- Create usage_sessions table
CREATE TABLE IF NOT EXISTS public.usage_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username TEXT NOT NULL,
    meta JSONB DEFAULT '{}'::jsonb,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_beat_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    active_ms BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Add constraints
    CHECK (active_ms >= 0),
    CHECK (last_beat_at >= started_at),
    CHECK (ended_at IS NULL OR ended_at >= started_at)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_usage_sessions_username ON public.usage_sessions(username);
CREATE INDEX IF NOT EXISTS idx_usage_sessions_started_at ON public.usage_sessions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_usage_sessions_ended_at ON public.usage_sessions(ended_at DESC);
CREATE INDEX IF NOT EXISTS idx_usage_sessions_active ON public.usage_sessions(username, ended_at) WHERE ended_at IS NULL;

-- Enable Row Level Security (RLS)
ALTER TABLE public.usage_sessions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (drop existing policies if they exist for idempotency)

-- Allow all authenticated users to view all sessions (for leaderboards, stats, etc.)
DROP POLICY IF EXISTS "Anyone can view usage sessions" ON public.usage_sessions;
CREATE POLICY "Anyone can view usage sessions" ON public.usage_sessions
    FOR SELECT USING (true);

-- Allow users to insert their own sessions
DROP POLICY IF EXISTS "Users can create their own sessions" ON public.usage_sessions;
CREATE POLICY "Users can create their own sessions" ON public.usage_sessions
    FOR INSERT WITH CHECK (true);

-- Allow users to update their own sessions (for heartbeats and ending sessions)
DROP POLICY IF EXISTS "Users can update their own sessions" ON public.usage_sessions;
CREATE POLICY "Users can update their own sessions" ON public.usage_sessions
    FOR UPDATE USING (true);

-- Optional: Create a view for session analytics
CREATE OR REPLACE VIEW public.usage_session_stats AS
SELECT 
    username,
    COUNT(*) as total_sessions,
    SUM(active_ms) as total_active_ms,
    AVG(active_ms) as avg_active_ms,
    MAX(active_ms) as max_active_ms,
    MIN(active_ms) as min_active_ms,
    MAX(last_beat_at) as last_activity,
    COUNT(*) FILTER (WHERE ended_at IS NULL) as active_sessions
FROM public.usage_sessions
GROUP BY username;

-- Grant access to the view
GRANT SELECT ON public.usage_session_stats TO authenticated, anon;

-- Create function to get active session duration
CREATE OR REPLACE FUNCTION public.get_active_session_duration(session_id UUID)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    session_started_at TIMESTAMP WITH TIME ZONE;
    session_last_beat TIMESTAMP WITH TIME ZONE;
    duration_ms BIGINT;
BEGIN
    SELECT started_at, last_beat_at
    INTO session_started_at, session_last_beat
    FROM public.usage_sessions
    WHERE id = session_id;
    
    IF session_started_at IS NULL THEN
        RETURN 0;
    END IF;
    
    duration_ms := EXTRACT(EPOCH FROM (session_last_beat - session_started_at)) * 1000;
    
    RETURN duration_ms;
END;
$$;

-- Create function to get user total active time
CREATE OR REPLACE FUNCTION public.get_user_total_active_time(user_name TEXT)
RETURNS TABLE (
    total_sessions BIGINT,
    total_active_ms BIGINT,
    total_active_minutes BIGINT,
    total_active_hours NUMERIC,
    average_session_minutes BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT as total_sessions,
        SUM(active_ms)::BIGINT as total_active_ms,
        (SUM(active_ms) / 60000)::BIGINT as total_active_minutes,
        ROUND((SUM(active_ms) / 3600000.0)::NUMERIC, 2) as total_active_hours,
        (AVG(active_ms) / 60000)::BIGINT as average_session_minutes
    FROM public.usage_sessions
    WHERE username = user_name;
END;
$$;

-- Create function to clean up old inactive sessions (optional maintenance)
CREATE OR REPLACE FUNCTION public.cleanup_abandoned_sessions()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    -- End sessions that haven't had a heartbeat in over 1 hour and aren't already ended
    UPDATE public.usage_sessions
    SET ended_at = last_beat_at
    WHERE ended_at IS NULL
    AND last_beat_at < NOW() - INTERVAL '1 hour';
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    
    RETURN updated_count;
END;
$$;

-- Optional: Create a scheduled job to run cleanup (requires pg_cron extension)
-- SELECT cron.schedule('cleanup-abandoned-sessions', '0 * * * *', 'SELECT public.cleanup_abandoned_sessions()');

COMMENT ON TABLE public.usage_sessions IS 'Tracks user session activity including start time, heartbeats, and total active time';
COMMENT ON COLUMN public.usage_sessions.meta IS 'JSON metadata about the session (e.g., app version, features used, etc.)';
COMMENT ON COLUMN public.usage_sessions.active_ms IS 'Total active time in milliseconds for this session';
COMMENT ON COLUMN public.usage_sessions.last_beat_at IS 'Last heartbeat timestamp to track session liveness';
