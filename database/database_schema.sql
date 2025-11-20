-- PokePoP Database Schema for Multi-Trainer Pokemon Inventory System
-- Run this in your Supabase SQL Editor

-- Create trainers table
CREATE TABLE IF NOT EXISTS public.trainers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    total_points INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure unique trainer names per user
    UNIQUE(user_id, name)
);

-- Create pokemon_inventory table
CREATE TABLE IF NOT EXISTS public.pokemon_inventory (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    trainer_id UUID REFERENCES public.trainers(id) ON DELETE CASCADE,
    pokemon_name TEXT NOT NULL,
    level INTEGER NOT NULL DEFAULT 1,
    points INTEGER NOT NULL DEFAULT 0,
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Add constraints
    CHECK (level > 0 AND level <= 100),
    CHECK (points >= 0)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_trainers_user_id ON public.trainers(user_id);
CREATE INDEX IF NOT EXISTS idx_trainers_total_points ON public.trainers(total_points DESC);
CREATE INDEX IF NOT EXISTS idx_pokemon_inventory_trainer_id ON public.pokemon_inventory(trainer_id);
CREATE INDEX IF NOT EXISTS idx_pokemon_inventory_captured_at ON public.pokemon_inventory(captured_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.trainers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pokemon_inventory ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for trainers table
CREATE POLICY "Users can view all trainers" ON public.trainers
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own trainers" ON public.trainers
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own trainers" ON public.trainers
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own trainers" ON public.trainers
    FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for pokemon_inventory table
CREATE POLICY "Users can view all pokemon inventories" ON public.pokemon_inventory
    FOR SELECT USING (true);

CREATE POLICY "Users can insert pokemon for their trainers" ON public.pokemon_inventory
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.trainers 
            WHERE trainers.id = trainer_id 
            AND trainers.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update pokemon in their trainers" ON public.pokemon_inventory
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.trainers 
            WHERE trainers.id = trainer_id 
            AND trainers.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete pokemon from their trainers" ON public.pokemon_inventory
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.trainers 
            WHERE trainers.id = trainer_id 
            AND trainers.user_id = auth.uid()
        )
    );

-- Create a function to automatically update trainer points when pokemon are added/removed
CREATE OR REPLACE FUNCTION update_trainer_total_points()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the trainer's total points
    UPDATE public.trainers 
    SET total_points = (
        SELECT COALESCE(SUM(points), 0) 
        FROM public.pokemon_inventory 
        WHERE trainer_id = COALESCE(NEW.trainer_id, OLD.trainer_id)
    ),
    updated_at = NOW()
    WHERE id = COALESCE(NEW.trainer_id, OLD.trainer_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update trainer points
CREATE TRIGGER trigger_update_trainer_points_insert
    AFTER INSERT ON public.pokemon_inventory
    FOR EACH ROW EXECUTE FUNCTION update_trainer_total_points();

CREATE TRIGGER trigger_update_trainer_points_update
    AFTER UPDATE ON public.pokemon_inventory
    FOR EACH ROW EXECUTE FUNCTION update_trainer_total_points();

CREATE TRIGGER trigger_update_trainer_points_delete
    AFTER DELETE ON public.pokemon_inventory
    FOR EACH ROW EXECUTE FUNCTION update_trainer_total_points();

-- Create a view for trainer leaderboard with pokemon count
-- Create automatic sync function for trainer points
CREATE OR REPLACE FUNCTION update_trainer_total_points()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the trainer's total_points based on sum of their Pokemon inventory
    UPDATE public.trainers
    SET total_points = COALESCE(
        (SELECT SUM(points) 
         FROM public.pokemon_inventory 
         WHERE trainer_id = COALESCE(NEW.trainer_id, OLD.trainer_id)),
        0
    ),
    updated_at = NOW()
    WHERE id = COALESCE(NEW.trainer_id, OLD.trainer_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS sync_trainer_points_on_insert ON public.pokemon_inventory;
DROP TRIGGER IF EXISTS sync_trainer_points_on_update ON public.pokemon_inventory;
DROP TRIGGER IF EXISTS sync_trainer_points_on_delete ON public.pokemon_inventory;

-- Trigger when a new Pokemon is captured (INSERT)
CREATE TRIGGER sync_trainer_points_on_insert
    AFTER INSERT ON public.pokemon_inventory
    FOR EACH ROW
    EXECUTE FUNCTION update_trainer_total_points();

-- Trigger when Pokemon points are updated (UPDATE)
CREATE TRIGGER sync_trainer_points_on_update
    AFTER UPDATE ON public.pokemon_inventory
    FOR EACH ROW
    EXECUTE FUNCTION update_trainer_total_points();

-- Trigger when a Pokemon is deleted (DELETE)
CREATE TRIGGER sync_trainer_points_on_delete
    AFTER DELETE ON public.pokemon_inventory
    FOR EACH ROW
    EXECUTE FUNCTION update_trainer_total_points();

-- Create leaderboard view (uses trainers.total_points which is now auto-synced)
CREATE OR REPLACE VIEW public.trainer_leaderboard AS
SELECT 
    t.id,
    t.name,
    t.total_points,
    t.created_at,
    COUNT(pi.id) as pokemon_count,
    t.user_id
FROM public.trainers t
LEFT JOIN public.pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.total_points, t.created_at, t.user_id
ORDER BY t.total_points DESC, t.created_at ASC;

-- Grant necessary permissions
GRANT ALL ON public.trainers TO authenticated;
GRANT ALL ON public.pokemon_inventory TO authenticated;
GRANT SELECT ON public.trainer_leaderboard TO authenticated;

-- Insert some sample data (optional)
-- You can uncomment this if you want some test data
/*
INSERT INTO public.trainers (user_id, name, total_points) VALUES
    ((SELECT auth.uid()), 'Ash', 2500),
    ((SELECT auth.uid()), 'Misty', 1800),
    ((SELECT auth.uid()), 'Brock', 2100);

-- Note: Replace with actual trainer IDs after running the above
INSERT INTO public.pokemon_inventory (trainer_id, pokemon_name, level, points) VALUES
    ((SELECT id FROM public.trainers WHERE name = 'Ash' LIMIT 1), 'Pikachu', 25, 500),
    ((SELECT id FROM public.trainers WHERE name = 'Ash' LIMIT 1), 'Charizard', 50, 1000),
    ((SELECT id FROM public.trainers WHERE name = 'Ash' LIMIT 1), 'Blastoise', 45, 900),
    ((SELECT id FROM public.trainers WHERE name = 'Misty' LIMIT 1), 'Staryu', 30, 600),
    ((SELECT id FROM public.trainers WHERE name = 'Misty' LIMIT 1), 'Psyduck', 20, 400);
*/