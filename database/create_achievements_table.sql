-- Create achievements/milestones system for PokePoP
-- Run this in your Supabase SQL Editor

-- Drop existing tables to start fresh (this will remove any existing achievement data)
DROP TABLE IF EXISTS public.user_achievements CASCADE;
DROP TABLE IF EXISTS public.user_stats CASCADE;
DROP TABLE IF EXISTS public.achievements CASCADE;

-- Create achievements table (defines all possible achievements)
CREATE TABLE public.achievements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    achievement_key TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL, -- 'first_capture', 'login_streak', 'total_captures', 'region_complete', 'duration'
    requirement_value INTEGER NOT NULL, -- The value needed (e.g., 5 for "Capture 5 monsters")
    icon TEXT, -- Optional emoji or icon identifier
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_achievements table (tracks which achievements each user has earned)
CREATE TABLE public.user_achievements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    trainer_id UUID REFERENCES public.trainers(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES public.achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure user can't unlock same achievement twice
    UNIQUE(user_id, achievement_id)
);

-- Create user_stats table to track progress towards achievements
CREATE TABLE public.user_stats (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    trainer_id UUID REFERENCES public.trainers(id) ON DELETE CASCADE,
    
    -- Capture stats
    total_captures INTEGER DEFAULT 0,
    forest_captures INTEGER DEFAULT 0,
    beach_captures INTEGER DEFAULT 0,
    volcano_captures INTEGER DEFAULT 0,
    swamp_captures INTEGER DEFAULT 0,
    
    -- Login streak
    current_login_streak INTEGER DEFAULT 0,
    longest_login_streak INTEGER DEFAULT 0,
    last_login_date DATE,
    
    -- Session duration (in minutes)
    total_duration_minutes INTEGER DEFAULT 0,
    longest_session_minutes INTEGER DEFAULT 0,
    
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can view achievements" ON public.achievements;
DROP POLICY IF EXISTS "Users can view achievements" ON public.user_achievements;
DROP POLICY IF EXISTS "Users can insert achievements" ON public.user_achievements;
DROP POLICY IF EXISTS "Users can view their own achievements" ON public.user_achievements;
DROP POLICY IF EXISTS "Users can insert their own achievements" ON public.user_achievements;
DROP POLICY IF EXISTS "Users can view stats" ON public.user_stats;
DROP POLICY IF EXISTS "Users can update stats" ON public.user_stats;
DROP POLICY IF EXISTS "Users can insert stats" ON public.user_stats;
DROP POLICY IF EXISTS "Users can view their own stats" ON public.user_stats;
DROP POLICY IF EXISTS "Users can update their own stats" ON public.user_stats;
DROP POLICY IF EXISTS "Users can insert their own stats" ON public.user_stats;

-- RLS Policies for achievements (everyone can view)
CREATE POLICY "Anyone can view achievements" ON public.achievements
    FOR SELECT USING (true);

-- RLS Policies for user_achievements (allow all authenticated access)
CREATE POLICY "Users can view achievements" ON public.user_achievements
    FOR SELECT USING (true);

CREATE POLICY "Users can insert achievements" ON public.user_achievements
    FOR INSERT WITH CHECK (true);

-- RLS Policies for user_stats (allow all authenticated access)
CREATE POLICY "Users can view stats" ON public.user_stats
    FOR SELECT USING (true);

CREATE POLICY "Users can update stats" ON public.user_stats
    FOR UPDATE USING (true);

CREATE POLICY "Users can insert stats" ON public.user_stats
    FOR INSERT WITH CHECK (true);

-- Insert all achievement definitions
INSERT INTO public.achievements (achievement_key, title, description, category, requirement_value, icon) VALUES
-- First capture
('first_capture', 'First Catch!', 'Captured your first Pokemon', 'first_capture', 1, '🎣'),

-- Login streaks
('login_streak_1', 'Dedicated Trainer', 'Login for 1 day', 'login_streak', 1, '📅'),
('login_streak_2', 'Consistent Trainer', 'Login for 2 days in a row', 'login_streak', 2, '📅'),
('login_streak_3', 'Committed Trainer', 'Login for 3 days in a row', 'login_streak', 3, '📅'),
('login_streak_4', 'Persistent Trainer', 'Login for 4 days in a row', 'login_streak', 4, '📅'),
('login_streak_5', 'Master Trainer', 'Login for 5 days in a row', 'login_streak', 5, '🏆'),

-- Total captures
('capture_5', 'Novice Collector', 'Captured 5 Pokemon', 'total_captures', 5, '⭐'),
('capture_10', 'Intermediate Collector', 'Captured 10 Pokemon', 'total_captures', 10, '⭐⭐'),
('capture_15', 'Advanced Collector', 'Captured 15 Pokemon', 'total_captures', 15, '⭐⭐⭐'),
('capture_20', 'Expert Collector', 'Captured 20 Pokemon', 'total_captures', 20, '👑'),

-- Region complete (capture all unique Pokemon in a region)
('forest_complete', 'Forest Master', 'Captured all Pokemon in Forest region', 'region_complete', 1, '🌲'),
('beach_complete', 'Beach Master', 'Captured all Pokemon in Beach region', 'region_complete', 2, '🏖️'),
('volcano_complete', 'Volcano Master', 'Captured all Pokemon in Volcano region', 'region_complete', 3, '🌋'),
('swamp_complete', 'Swamp Master', 'Captured all Pokemon in Swamp region', 'region_complete', 4, '🐸'),

-- Duration milestones (total playtime in minutes)
('duration_60', 'Engaged Player', 'Played for 60 minutes total', 'duration', 60, '⏰'),
('duration_90', 'Dedicated Player', 'Played for 90 minutes total', 'duration', 90, '⏰⏰'),
('duration_120', 'Hardcore Player', 'Played for 120 minutes total', 'duration', 120, '⏰⏰⏰');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON public.user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_trainer_id ON public.user_achievements(trainer_id);
CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON public.user_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_achievements_category ON public.achievements(category);

-- Function to check and award achievements
CREATE OR REPLACE FUNCTION check_and_award_achievements(
    p_user_id UUID,
    p_trainer_id UUID
)
RETURNS TABLE (
    newly_unlocked_achievement_id UUID,
    achievement_title TEXT,
    achievement_description TEXT,
    achievement_icon TEXT
) AS $$
DECLARE
    user_stat RECORD;
    achievement RECORD;
BEGIN
    -- Get current user stats
    SELECT * INTO user_stat FROM public.user_stats WHERE user_id = p_user_id;
    
    IF user_stat IS NULL THEN
        RETURN;
    END IF;
    
    -- Check each achievement category
    FOR achievement IN 
        SELECT * FROM public.achievements 
        WHERE id NOT IN (
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
               ((achievement.achievement_key = 'forest_complete' AND user_stat.forest_captures >= 6) OR
                (achievement.achievement_key = 'beach_complete' AND user_stat.beach_captures >= 6) OR
                (achievement.achievement_key = 'volcano_complete' AND user_stat.volcano_captures >= 6) OR
                (achievement.achievement_key = 'swamp_complete' AND user_stat.swamp_captures >= 6))
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
                achievement.icon;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user's unlocked achievements
CREATE OR REPLACE FUNCTION get_user_achievements(p_user_id UUID)
RETURNS TABLE (
    achievement_id UUID,
    achievement_key TEXT,
    title TEXT,
    description TEXT,
    category TEXT,
    icon TEXT,
    unlocked_at TIMESTAMP WITH TIME ZONE
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
        ua.unlocked_at
    FROM public.user_achievements ua
    JOIN public.achievements a ON ua.achievement_id = a.id
    WHERE ua.user_id = p_user_id
    ORDER BY ua.unlocked_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Verify setup
SELECT 'Achievements system setup complete!' as status;
SELECT COUNT(*) as total_achievements FROM public.achievements;
