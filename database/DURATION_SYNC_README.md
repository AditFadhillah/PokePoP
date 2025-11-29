# Auto-Sync Duration from Usage Sessions

## Overview
The `user_stats` table now automatically calculates `total_duration_minutes` and `longest_session_minutes` from the `usage_sessions` table's `active_ms` field.

## How It Works

### Data Flow
```
usage_sessions.active_ms (milliseconds)
    ↓
    Trigger fires when session ends (ended_at is set)
    ↓
    Calculate total & longest duration in minutes
    ↓
    Update user_stats.total_duration_minutes & longest_session_minutes
    ↓
    Check for duration-based achievements
```

### Calculations
- **total_duration_minutes** = SUM(all active_ms for user) / 60,000
- **longest_session_minutes** = MAX(active_ms for user) / 60,000

### Duration Achievements
- **duration_60** (60 min) - "Engaged Player"
- **duration_90** (90 min) - "Dedicated Player"
- **duration_120** (120 min) - "Hardcore Player"

## Setup

### Run the SQL Script
```sql
database/sync_duration_from_usage_sessions.sql
```

This script:
1. ✅ Backfills existing data from all completed sessions
2. ✅ Creates trigger to auto-update on session end
3. ✅ Shows verification queries

## What Changed

### Before
- Duration was manually updated via `updateSessionDuration()` function
- Could get out of sync with actual session data
- Required manual calls from frontend

### After
- Duration auto-calculated from `usage_sessions.active_ms`
- Always accurate and in sync
- No frontend changes needed
- Trigger fires automatically when session ends

## Database Changes

### New Trigger Function
```sql
sync_user_stats_duration()
```
- Triggers on INSERT or UPDATE of `usage_sessions`
- Only processes when `ended_at` is set (session completed)
- Calculates total and longest duration from all user sessions
- Updates `user_stats` automatically
- Checks for duration achievements

### Trigger
```sql
trigger_sync_duration_on_session_end
```
- Fires AFTER INSERT OR UPDATE OF ended_at, active_ms
- On `usage_sessions` table
- FOR EACH ROW

## Frontend Impact

### No Changes Required! ✅
The frontend `useUsageSession` hook already:
1. Creates session with `started_at`
2. Updates `last_beat_at` via heartbeats
3. Sets `ended_at` and `active_ms` when session ends

The trigger automatically handles the rest!

### Optional: Remove Manual Duration Updates
The `updateSessionDuration()` function in `achievementHelpers.ts` is now redundant and can be removed if desired. It's not being called anywhere, but could be kept for backward compatibility.

## Verification

### Check Current Duration Stats
```sql
SELECT 
    tu.username,
    us.total_duration_minutes,
    us.longest_session_minutes,
    (SELECT COUNT(*) FROM usage_sessions WHERE username = tu.username AND ended_at IS NOT NULL) as sessions
FROM test_username tu
JOIN user_stats us ON us.user_id = tu.id
ORDER BY us.total_duration_minutes DESC;
```

### Check Session Data vs Stats
```sql
SELECT 
    tu.username,
    us.total_duration_minutes as stats_total_min,
    ROUND(SUM(uss.active_ms) / 60000.0) as sessions_total_min,
    us.longest_session_minutes as stats_longest_min,
    ROUND(MAX(uss.active_ms) / 60000.0) as sessions_longest_min
FROM test_username tu
JOIN user_stats us ON us.user_id = tu.id
JOIN usage_sessions uss ON uss.username = tu.username AND uss.ended_at IS NOT NULL
GROUP BY tu.username, us.total_duration_minutes, us.longest_session_minutes;
```

Should show matching values!

## Benefits

1. ✅ **Single Source of Truth** - Duration comes from actual session data
2. ✅ **Always Accurate** - Auto-updates when sessions end
3. ✅ **No Manual Tracking** - Trigger handles everything
4. ✅ **Achievement Integration** - Auto-checks for duration achievements
5. ✅ **Backward Compatible** - Works with existing session tracking

## Testing

1. Login as a test user
2. Use the app for a few minutes
3. Logout or close the app (session ends)
4. Check `user_stats` - duration should be updated
5. If duration ≥ 60 minutes, check for duration achievements

## Example

User plays for 3 sessions:
- Session 1: 15 minutes (900,000 ms)
- Session 2: 25 minutes (1,500,000 ms)
- Session 3: 10 minutes (600,000 ms)

After all sessions end:
- `total_duration_minutes` = 50 (15 + 25 + 10)
- `longest_session_minutes` = 25 (max of 15, 25, 10)
- No duration achievement yet (need 60 min)

After 1 more session of 15 minutes:
- `total_duration_minutes` = 65 (50 + 15)
- 🎉 **duration_60** achievement unlocked!

## Notes

- Only completed sessions (with `ended_at`) are counted
- Active (ongoing) sessions are not included until they end
- Duration is recalculated from ALL sessions each time (not incremental)
- This ensures accuracy even if old data is corrected
