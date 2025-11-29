-- Create user_stats table for achievement tracking
-- This table tracks user statistics for achievement progress

CREATE TABLE IF NOT EXISTS user_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    trainer_id UUID REFERENCES trainers(id) ON DELETE CASCADE,
    
    -- Capture statistics
    total_captures INTEGER DEFAULT 0,
    forest_captures INTEGER DEFAULT 0,
    beach_captures INTEGER DEFAULT 0,
    volcano_captures INTEGER DEFAULT 0,
    swamp_captures INTEGER DEFAULT 0,
    
    -- Login streak statistics
    current_login_streak INTEGER DEFAULT 1,
    longest_login_streak INTEGER DEFAULT 1,
    last_login_date DATE,
    
    -- Session duration statistics
    total_duration_minutes INTEGER DEFAULT 0,
    longest_session_minutes INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Ensure one stats record per user
    UNIQUE(user_id)
);

-- Enable Row Level Security
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can read their own stats
CREATE POLICY "Users can view their own stats"
    ON user_stats
    FOR SELECT
    USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own stats
CREATE POLICY "Users can insert their own stats"
    ON user_stats
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own stats
CREATE POLICY "Users can update their own stats"
    ON user_stats
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON user_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_user_stats_trainer_id ON user_stats(trainer_id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_user_stats_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_stats_updated_at
    BEFORE UPDATE ON user_stats
    FOR EACH ROW
    EXECUTE FUNCTION update_user_stats_updated_at();

-- Verify table creation
SELECT 'user_stats table created successfully' AS status;
