# Capture Time Tracking

This document explains the capture time tracking system that records how long it takes users to solve programming challenges and capture Pokemon.

## Overview

The system tracks the duration from when a battle starts to when a Pokemon is successfully captured, storing the result in milliseconds. This enables:
- Performance metrics and user analytics
- Speed leaderboards
- Progress tracking over time
- Correlation between solve speed and skill level

## Database Schema

### Column Addition

```sql
-- Add capture_time_ms column to pokemon_inventory
ALTER TABLE public.pokemon_inventory 
ADD COLUMN IF NOT EXISTS capture_time_ms BIGINT;

-- Ensure non-negative values
ALTER TABLE public.pokemon_inventory 
ADD CONSTRAINT check_capture_time_positive 
CHECK (capture_time_ms IS NULL OR capture_time_ms >= 0);
```

### Updated pokemon_inventory Table

```sql
CREATE TABLE pokemon_inventory (
  id UUID PRIMARY KEY,
  trainer_id UUID REFERENCES trainers(id),
  pokemon_name TEXT NOT NULL,
  level INTEGER DEFAULT 1,
  points INTEGER DEFAULT 0,
  captured_at TIMESTAMP DEFAULT NOW(),
  capture_time_ms BIGINT,  -- NEW: Time to capture in milliseconds
  CHECK (level > 0 AND level <= 100),
  CHECK (points >= 0),
  CHECK (capture_time_ms IS NULL OR capture_time_ms >= 0)
);

-- Index for speed queries
CREATE INDEX IF NOT EXISTS idx_pokemon_inventory_capture_time 
ON public.pokemon_inventory(capture_time_ms);
```

## Implementation

### 1. Godot (GDScript) - Battle Scene

**File:** `game/PokemonTemplate/Scenes/Battle/battle.gd`

```gdscript
# Track battle start time
var battle_start_time: int = 0

func start_battle_timer():
    time_remaining = battle_timer
    timer_active = true
    battle_start_time = Time.get_ticks_msec()  # Record start time
    print("⏰ Battle Timer Started: ", battle_timer, " seconds")

func _trigger_capture():
    # Calculate capture duration
    var capture_time_ms = Time.get_ticks_msec() - battle_start_time
    
    print("⏱️ Capture Time: ", capture_time_ms, "ms (", capture_time_ms / 1000.0, " seconds)")
    
    # Send to React with capture time
    JSBridge.send_message_to_react("POKEMON_CAPTURED", {
        "pokemon_name": current_pokemon,
        "level": enemy_level,
        "points": total_points,
        "capture_time_ms": capture_time_ms,  # Include duration
        "captured_at": Time.get_datetime_string_from_system()
    })
```

### 2. TypeScript Interface

**File:** `src/lib/supabase.ts`

```typescript
export interface PokemonInventory {
  id: string
  trainer_id: string
  pokemon_name: string
  level: number
  points: number
  captured_at: string
  capture_time_ms?: number | null  // Duration in milliseconds
}
```

### 3. React Integration

**File:** `src/App.tsx`

```typescript
async function handlePokemonCapture(captureData: any) {
  const pokemonData = {
    name: captureData.data?.pokemon_name || 'Unknown',
    level: captureData.data?.level || 1,
    points: captureData.data?.points || 100,
    captured_at: captureData.data?.captured_at || new Date().toISOString(),
    capture_time_ms: captureData.data?.capture_time_ms || null
  }

  // Convert to seconds for display
  const captureTimeSeconds = pokemonData.capture_time_ms 
    ? (pokemonData.capture_time_ms / 1000).toFixed(2) 
    : null

  // Save to database
  await addPokemonToDatabase(trainer.id, pokemonData)
  
  // Display to user
  setOutput(`
    ${pokemonData.name} (Lv.${pokemonData.level}) captured!
    ⏱️ Solve Time: ${captureTimeSeconds}s
    ✨ Total: ${pokemonData.points} points
  `)
}

async function addPokemonToDatabase(trainerId: string, pokemonData: {
  name: string,
  level: number,
  points: number,
  captured_at: string,
  capture_time_ms?: number | null
}) {
  const { error } = await supabase
    .from('pokemon_inventory')
    .insert([{
      trainer_id: trainerId,
      pokemon_name: pokemonData.name,
      level: pokemonData.level,
      points: pokemonData.points,
      captured_at: pokemonData.captured_at,
      capture_time_ms: pokemonData.capture_time_ms  // Save duration
    }])
    
  return !error
}
```

## Console Output

When a Pokemon is captured, you'll see:

```
✅ Pokemon captured with 7 seconds remaining!
⏱️ Capture Time: 3245ms (3.245 seconds)
⏱️ Time Bonus: 70 points (70% remaining)
💰 Total Points: 170 (Base: 100 + Bonus: 70)
```

## Analytics Queries

### Fastest Captures Overall

```sql
SELECT 
  pokemon_name,
  level,
  capture_time_ms,
  capture_time_ms / 1000.0 as capture_seconds,
  points
FROM pokemon_inventory
WHERE capture_time_ms IS NOT NULL
ORDER BY capture_time_ms ASC
LIMIT 10;
```

### Average Solve Time by Pokemon

```sql
SELECT 
  pokemon_name,
  COUNT(*) as total_captures,
  AVG(capture_time_ms) as avg_time_ms,
  AVG(capture_time_ms) / 1000.0 as avg_seconds,
  MIN(capture_time_ms) / 1000.0 as fastest_seconds,
  MAX(capture_time_ms) / 1000.0 as slowest_seconds
FROM pokemon_inventory
WHERE capture_time_ms IS NOT NULL
GROUP BY pokemon_name
ORDER BY avg_time_ms ASC;
```

### User Performance Over Time

```sql
SELECT 
  trainer_id,
  DATE(captured_at) as capture_date,
  COUNT(*) as captures_today,
  AVG(capture_time_ms) / 1000.0 as avg_seconds,
  MIN(capture_time_ms) / 1000.0 as fastest_seconds
FROM pokemon_inventory
WHERE capture_time_ms IS NOT NULL
GROUP BY trainer_id, DATE(captured_at)
ORDER BY capture_date DESC, avg_seconds ASC;
```

### Speed Leaderboard (Last 30 Days)

```sql
SELECT 
  t.username,
  COUNT(*) as total_captures,
  AVG(pi.capture_time_ms) / 1000.0 as avg_solve_time_seconds,
  MIN(pi.capture_time_ms) / 1000.0 as fastest_solve_seconds,
  SUM(pi.points) as total_points
FROM pokemon_inventory pi
JOIN trainers t ON pi.trainer_id = t.id
WHERE pi.capture_time_ms IS NOT NULL
  AND pi.captured_at > NOW() - INTERVAL '30 days'
GROUP BY t.username
ORDER BY avg_solve_time_seconds ASC
LIMIT 20;
```

### Correlation: Speed vs Points

```sql
SELECT 
  CASE 
    WHEN capture_time_ms < 3000 THEN '< 3s (Fast)'
    WHEN capture_time_ms < 6000 THEN '3-6s (Medium)'
    WHEN capture_time_ms < 9000 THEN '6-9s (Slow)'
    ELSE '9s+ (Very Slow)'
  END as speed_category,
  COUNT(*) as captures,
  AVG(points) as avg_points,
  AVG(level) as avg_level
FROM pokemon_inventory
WHERE capture_time_ms IS NOT NULL
GROUP BY speed_category
ORDER BY MIN(capture_time_ms);
```

## Future Enhancements

### Leaderboard UI
Display fastest solvers in the game interface:
```typescript
const [fastestCaptures, setFastestCaptures] = useState<Array<{
  username: string
  pokemon_name: string
  capture_time_ms: number
  level: number
}>>([])

async function loadLeaderboard() {
  const { data } = await supabase
    .from('pokemon_inventory')
    .select('trainer_id, pokemon_name, level, capture_time_ms')
    .order('capture_time_ms', { ascending: true })
    .limit(10)
  
  setFastestCaptures(data || [])
}
```

### Personal Best Tracking
Track each user's fastest capture per Pokemon:
```sql
CREATE VIEW user_personal_bests AS
SELECT DISTINCT ON (trainer_id, pokemon_name)
  trainer_id,
  pokemon_name,
  capture_time_ms as best_time_ms,
  capture_time_ms / 1000.0 as best_time_seconds,
  captured_at as achieved_at
FROM pokemon_inventory
WHERE capture_time_ms IS NOT NULL
ORDER BY trainer_id, pokemon_name, capture_time_ms ASC;
```

### Difficulty Adjustment
Use average solve times to adjust Pokemon difficulty:
```gdscript
func calculate_pokemon_level(base_level: int, pokemon_name: String) -> int:
    var avg_solve_time = get_average_solve_time(pokemon_name)
    
    # If players solve too quickly, increase difficulty
    if avg_solve_time < 5000:  # Less than 5 seconds
        return base_level + 2
    elif avg_solve_time < 8000:  # Less than 8 seconds
        return base_level + 1
    
    return base_level
```

## Migration Steps

1. **Run the SQL migration:**
   ```bash
   # In Supabase SQL Editor
   cat database/add_capture_time_column.sql | psql $DATABASE_URL
   ```

2. **Update TypeScript types:**
   - Already done in `src/lib/supabase.ts`

3. **Update Godot game:**
   - Already done in `battle.gd`

4. **Update React app:**
   - Already done in `src/App.tsx`

5. **Test the feature:**
   - Start a battle
   - Solve the challenge
   - Check console for capture time
   - Verify database has `capture_time_ms` value

## Data Validation

The system ensures data integrity with:
- `CHECK (capture_time_ms >= 0)` - No negative times
- `NULL` values allowed for legacy captures
- Index on `capture_time_ms` for fast queries
- Console logging for debugging

## Related Features

- **Battle Timer:** 10-second countdown with flee mechanic
- **Time Bonus:** Percentage-based bonus points for fast solves
- **Usage Sessions:** Overall session duration tracking
- **Capture Time:** Per-challenge solve duration

Together, these features provide comprehensive performance tracking across both session-level (total time in app) and challenge-level (individual solve times) metrics.
