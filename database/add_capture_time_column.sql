-- Add capture_time_ms column to pokemon_inventory table
-- This tracks how long it took to capture the Pokemon in milliseconds

-- Add the new column
ALTER TABLE public.pokemon_inventory 
ADD COLUMN IF NOT EXISTS capture_time_ms BIGINT;

-- Add constraint to ensure positive values
ALTER TABLE public.pokemon_inventory 
DROP CONSTRAINT IF EXISTS check_capture_time_positive;

ALTER TABLE public.pokemon_inventory 
ADD CONSTRAINT check_capture_time_positive CHECK (capture_time_ms IS NULL OR capture_time_ms >= 0);

-- Add comment for documentation
COMMENT ON COLUMN public.pokemon_inventory.capture_time_ms IS 'Time taken to capture the Pokemon in milliseconds (from battle start to successful capture)';

-- Optional: Create an index if you plan to query by capture speed
CREATE INDEX IF NOT EXISTS idx_pokemon_inventory_capture_time ON public.pokemon_inventory(capture_time_ms);

-- Example query to see fastest captures
-- SELECT pokemon_name, level, capture_time_ms / 1000.0 as capture_seconds 
-- FROM pokemon_inventory 
-- WHERE capture_time_ms IS NOT NULL 
-- ORDER BY capture_time_ms ASC 
-- LIMIT 10;
