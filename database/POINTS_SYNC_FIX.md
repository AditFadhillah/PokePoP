# Trainer Points Synchronization Fix

## Problem

The `trainers` table's `total_points` column was getting out of sync with the actual sum of Pokemon points in the `pokemon_inventory` table, causing discrepancies between:
- In-game inventory display (shows calculated sum)
- Leaderboard (shows cached total_points)
- Trainers table (shows cached total_points)

### Example Issue:
- **test1 trainer**: 
  - trainers table showed: 3201 points
  - trainer_leaderboard view showed: 3003 points  
  - Actual Pokemon inventory sum: 3003 points

## Solution

Implemented **automatic database triggers** that keep `trainers.total_points` synchronized with the Pokemon inventory at all times.

### How It Works:

1. **Function**: `update_trainer_total_points()`
   - Recalculates total points from Pokemon inventory
   - Updates the trainer's record automatically
   - Updates the `updated_at` timestamp

2. **Triggers**: Automatically fire on:
   - `INSERT` - When a Pokemon is captured
   - `UPDATE` - When Pokemon points are modified
   - `DELETE` - When a Pokemon is removed
   
3. **Result**: The `trainers.total_points` always matches the sum of their Pokemon points

## Files Modified/Created

### New Files:
- `auto_sync_trainer_points.sql` - Complete fix with triggers + data sync
- `fix_leaderboard_calculation.sql` - Alternative approach (calculates in view)
- `sync_trainer_points.sql` - One-time sync script

### Modified Files:
- `database_schema.sql` - Added triggers to main schema

## How to Apply the Fix

### Option 1: Run the Auto-Sync Script (RECOMMENDED)
```sql
-- Run this in Supabase SQL Editor:
-- File: auto_sync_trainer_points.sql

-- This will:
-- 1. Create the sync function
-- 2. Create triggers on pokemon_inventory
-- 3. Fix existing discrepancies
-- 4. Show verification results
```

### Option 2: Rebuild Database with New Schema
```sql
-- Drop and recreate tables using updated database_schema.sql
-- WARNING: This will delete all data!
```

## Verification

After applying the fix, run this query to verify everything is in sync:

```sql
SELECT 
    t.id,
    t.name,
    t.total_points as trainers_table_points,
    COALESCE(SUM(pi.points), 0) as inventory_sum,
    t.total_points - COALESCE(SUM(pi.points), 0) as difference,
    COUNT(pi.id) as pokemon_count
FROM public.trainers t
LEFT JOIN public.pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.total_points
HAVING t.total_points - COALESCE(SUM(pi.points), 0) != 0
ORDER BY ABS(t.total_points - COALESCE(SUM(pi.points), 0)) DESC;
```

**Expected Result**: No rows (difference should be 0 for all trainers)

## Testing

Test that the triggers work correctly:

```sql
-- 1. Capture a new Pokemon
INSERT INTO pokemon_inventory (trainer_id, pokemon_name, level, points)
VALUES ('your-trainer-id', 'PIKACHU', 1, 100);

-- 2. Check trainer points increased by 100
SELECT name, total_points FROM trainers WHERE id = 'your-trainer-id';

-- 3. Delete the Pokemon  
DELETE FROM pokemon_inventory WHERE trainer_id = 'your-trainer-id' AND pokemon_name = 'PIKACHU';

-- 4. Check trainer points decreased by 100
SELECT name, total_points FROM trainers WHERE id = 'your-trainer-id';
```

## Benefits

✅ **Automatic synchronization** - No manual updates needed  
✅ **Data integrity** - trainers.total_points always accurate  
✅ **Consistent displays** - Leaderboard matches inventory  
✅ **Real-time updates** - Points update instantly on capture/delete  
✅ **No application changes** - Fix is entirely database-side  

## Future Considerations

The `trainers.total_points` column is now redundant since it's automatically calculated. Consider:

1. **Keep it** (current approach) - For performance and backward compatibility
2. **Remove it** - Calculate on-the-fly in views (use `fix_leaderboard_calculation.sql` approach)

Current approach is recommended for better performance on leaderboard queries.
