# Implementation Summary: Capture Time Tracking

## What Was Implemented

Added a complete system to track how long it takes users to solve programming challenges and capture Pokemon.

## Changes Made

### 1. Database Migration
**File:** `database/add_capture_time_column.sql` (NEW)
- Added `capture_time_ms BIGINT` column to `pokemon_inventory` table
- Added CHECK constraint to ensure non-negative values
- Created index for performance on time-based queries
- Includes sample analytics queries

### 2. Fixed SQL Migration Idempotency
**File:** `database/usage_sessions_migration.sql` (UPDATED)
- Added `DROP POLICY IF EXISTS` before each policy creation
- Prevents "policy already exists" error on re-run
- Now safe to run multiple times

### 3. Godot Game Logic
**File:** `game/PokemonTemplate/Scenes/Battle/battle.gd` (UPDATED)
- Added `battle_start_time: int = 0` variable to track when battle starts
- Modified `start_battle_timer()` to record `Time.get_ticks_msec()`
- Modified `_trigger_capture()` to calculate duration: `Time.get_ticks_msec() - battle_start_time`
- Added console output: "⏱️ Capture Time: Xms (Y seconds)"
- Included `capture_time_ms` in POKEMON_CAPTURED message to React

### 4. TypeScript Interface
**File:** `src/lib/supabase.ts` (UPDATED)
- Added `capture_time_ms?: number | null` to `PokemonInventory` interface
- Properly typed for TypeScript safety

### 5. React Integration
**File:** `src/App.tsx` (UPDATED)
- Updated `handlePokemonCapture()` to extract `capture_time_ms` from Godot message
- Calculates `captureTimeSeconds = (capture_time_ms / 1000).toFixed(2)` for display
- Updated output message to show: "⏱️ Solve Time: X.XXs"
- Updated `addPokemonToDatabase()` function signature to include `capture_time_ms` parameter
- Database insert now includes `capture_time_ms` field

### 6. Documentation
**File:** `CAPTURE_TIME_TRACKING.md` (NEW)
- Comprehensive documentation of the feature
- Code examples from all layers (Godot, TypeScript, React)
- Analytics queries for leaderboards and performance tracking
- Future enhancement ideas
- Migration steps

## How It Works

### Flow Diagram
```
Battle Starts → start_battle_timer()
    ↓
Record battle_start_time = Time.get_ticks_msec()
    ↓
User solves challenge
    ↓
_trigger_capture()
    ↓
Calculate: capture_time_ms = Time.get_ticks_msec() - battle_start_time
    ↓
Send POKEMON_CAPTURED with capture_time_ms
    ↓
React receives message
    ↓
Convert to seconds for display
    ↓
Save to database with capture_time_ms
    ↓
Show user: "⏱️ Solve Time: 3.24s"
```

### Example Output

**Console (Godot):**
```
⏰ Battle Timer Started: 10.0 seconds
✅ Pokemon captured with 7 seconds remaining!
⏱️ Capture Time: 3245ms (3.245 seconds)
⏱️ Time Bonus: 70 points (70% remaining)
💰 Total Points: 170 (Base: 100 + Bonus: 70)
```

**UI Message (React):**
```
CATERPIE (Lv.1) captured and saved to database!

⏱️ Solve Time: 3.24s
💰 Base Points: 100
⏱️ Time Bonus: +70 (70% remaining)
✨ Total: 170 points
```

**Database Record:**
```json
{
  "id": "uuid...",
  "trainer_id": "uuid...",
  "pokemon_name": "CATERPIE",
  "level": 1,
  "points": 170,
  "captured_at": "2024-01-15T10:30:45.123Z",
  "capture_time_ms": 3245
}
```

## Analytics Queries Available

### 1. Fastest Captures
```sql
SELECT pokemon_name, level, capture_time_ms / 1000.0 as seconds
FROM pokemon_inventory
WHERE capture_time_ms IS NOT NULL
ORDER BY capture_time_ms ASC
LIMIT 10;
```

### 2. Average Solve Time by Pokemon
```sql
SELECT 
  pokemon_name,
  COUNT(*) as captures,
  AVG(capture_time_ms) / 1000.0 as avg_seconds
FROM pokemon_inventory
WHERE capture_time_ms IS NOT NULL
GROUP BY pokemon_name;
```

### 3. Speed Leaderboard
```sql
SELECT 
  t.username,
  AVG(pi.capture_time_ms) / 1000.0 as avg_solve_time,
  MIN(pi.capture_time_ms) / 1000.0 as fastest_solve
FROM pokemon_inventory pi
JOIN trainers t ON pi.trainer_id = t.id
WHERE pi.capture_time_ms IS NOT NULL
GROUP BY t.username
ORDER BY avg_solve_time ASC;
```

## Testing Checklist

- [x] SQL migration created with idempotent statements
- [x] TypeScript interface updated
- [x] Godot tracks battle start time
- [x] Godot calculates capture duration
- [x] Godot sends capture_time_ms to React
- [x] React extracts capture_time_ms from message
- [x] React displays solve time to user
- [x] React saves capture_time_ms to database
- [x] Database constraint prevents negative values
- [x] Documentation created with examples
- [x] Analytics queries provided

## Next Steps

To use this feature:

1. **Run the migration:**
   ```sql
   -- In Supabase SQL Editor, paste contents of:
   database/add_capture_time_column.sql
   ```

2. **Re-export the Godot game:**
   - Open Godot project
   - Export to Web
   - Copy files to `public/game/web/`

3. **Test the feature:**
   - Start the app: `npm run dev`
   - Login as a trainer
   - Start a battle
   - Solve the challenge
   - Check console for timing logs
   - Verify database has capture_time_ms value

4. **Build analytics:**
   - Query fastest captures
   - Create leaderboards
   - Track improvement over time

## Benefits

✅ **Performance Tracking:** Know exactly how fast users solve challenges  
✅ **Leaderboards:** Rank users by solve speed  
✅ **Progress Monitoring:** See improvement over time  
✅ **Difficulty Tuning:** Adjust challenge difficulty based on average solve times  
✅ **User Engagement:** Gamify speed with time-based rewards  
✅ **Data-Driven Decisions:** Make informed changes based on solve time metrics  

## Related Systems

- **Battle Timer:** 10-second countdown (hidden from player)
- **Time Bonus:** Percentage-based bonus points for speed
- **Usage Sessions:** Track overall session duration
- **Capture Time:** Track per-challenge solve duration

Together, these provide complete performance analytics from session-level to challenge-level granularity.
