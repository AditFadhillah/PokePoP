# Usage Sessions Integration

This document explains how to use the usage sessions tracking feature in PokePoP.

## Overview

The usage sessions feature tracks user activity time in the application. It automatically:
- Creates a session when a user logs in or starts playing
- Sends periodic heartbeats (every 30 seconds) to track active time
- Ends the session when the user logs out or closes the app
- Pauses tracking when the browser tab is hidden

## Database Setup

1. Run the migration script in Supabase SQL Editor:
   ```bash
   # Copy contents of database/usage_sessions_migration.sql
   # Paste into Supabase SQL Editor and run
   ```

2. The migration creates:
   - `usage_sessions` table
   - Indexes for performance
   - RLS policies for security
   - Helper views and functions

## Table Structure

```typescript
interface UsageSession {
  id: string                 // UUID primary key
  username: string           // User identifier
  meta: any                  // JSON metadata (device info, app state, etc.)
  started_at: string         // Session start timestamp
  last_beat_at: string       // Last heartbeat timestamp
  ended_at: string | null    // Session end timestamp (null if active)
  active_ms: number          // Total active time in milliseconds
  created_at: string         // Record creation timestamp
}
```

## Metadata Format

The `meta` column automatically tracks:
```json
{
  "ua": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)...",
  "platform": "Win32",
  "language": "en-US",
  "screenResolution": "1920x1080",
  "viewport": "1366x768",
  "timezone": "America/New_York",
  "appView": "main",
  "gameStatus": "battle",
  "trainer": "Ash"
}
```

## Usage in App

### Automatic Tracking (Already Integrated)

The App.tsx already includes automatic session tracking:

```typescript
import { useUsageSession } from './lib/useUsageSession'

const usageSession = useUsageSession(
  currentAppUser?.username || null,
  {
    appView: appView,
    gameStatus: gameStatus,
    trainer: currentTrainer?.name
  }
)
```

This automatically:
- Starts a session when `currentAppUser` is set
- Captures device info (user agent, screen size, timezone, etc.)
- Tracks metadata like current view and game status
- Sends heartbeats every 30 seconds
- Ends the session on logout or browser close
- Pauses tracking when tab is hidden

### Manual Control

You can also manually control sessions:

```typescript
const { 
  sessionId, 
  sessionActive, 
  getActiveTimeSeconds,
  getActiveTimeMinutes,
  endSession 
} = useUsageSession(username, metadata)

// Get current active time
console.log('Active for:', getActiveTimeSeconds(), 'seconds')

// Manually end session
await endSession()
```

## Database Operations

### Create a Session

```typescript
const { data, error } = await dbHelpers.createUsageSession(
  'username',
  { appVersion: '1.0', feature: 'game' }
)
```

### Update Heartbeat

```typescript
const { data, error } = await dbHelpers.updateSessionHeartbeat(
  sessionId,
  activeTimeMs
)
```

### End Session

```typescript
const { data, error } = await dbHelpers.endUsageSession(
  sessionId,
  totalActiveTimeMs
)
```

### Get User Sessions

```typescript
const { data, error } = await dbHelpers.getUserSessions('username')
```

### Get Active Sessions

```typescript
const { data, error } = await dbHelpers.getActiveSessions()
```

### Get User Statistics

```typescript
const { data, error } = await dbHelpers.getUserSessionStats('username')

// Returns:
// {
//   totalSessions: 10,
//   totalActiveMs: 3600000,
//   averageSessionMs: 360000,
//   totalActiveMinutes: 60,
//   averageSessionMinutes: 6
// }
```

## SQL Functions

### Get Total Active Time

```sql
SELECT * FROM get_user_total_active_time('username');

-- Returns:
-- total_sessions | total_active_ms | total_active_minutes | total_active_hours | average_session_minutes
-- 10             | 3600000         | 60                   | 1.00               | 6
```

### Cleanup Abandoned Sessions

```sql
SELECT cleanup_abandoned_sessions();

-- Automatically ends sessions that haven't had a heartbeat in over 1 hour
```

## Analytics Queries

### Top Active Users

```sql
SELECT 
  username,
  total_sessions,
  total_active_ms / 60000 as total_minutes,
  avg_active_ms / 60000 as avg_session_minutes
FROM usage_session_stats
ORDER BY total_active_ms DESC
LIMIT 10;
```

### Recent Activity

```sql
SELECT 
  username,
  started_at,
  ended_at,
  active_ms / 60000 as active_minutes,
  meta
FROM usage_sessions
WHERE started_at > NOW() - INTERVAL '24 hours'
ORDER BY started_at DESC;
```

### Active Users Right Now

```sql
SELECT 
  username,
  started_at,
  last_beat_at,
  active_ms / 60000 as active_minutes
FROM usage_sessions
WHERE ended_at IS NULL
AND last_beat_at > NOW() - INTERVAL '5 minutes'
ORDER BY last_beat_at DESC;
```

### Daily Usage Statistics

```sql
SELECT 
  DATE(started_at) as date,
  COUNT(DISTINCT username) as unique_users,
  COUNT(*) as total_sessions,
  SUM(active_ms) / 60000 as total_active_minutes,
  AVG(active_ms) / 60000 as avg_session_minutes
FROM usage_sessions
WHERE started_at > NOW() - INTERVAL '30 days'
GROUP BY DATE(started_at)
ORDER BY date DESC;
```

## Metadata Best Practices

Store useful context in the `meta` field:

```typescript
{
  appView: 'main',           // Current view/screen
  gameStatus: 'battle',       // Game state
  trainer: 'Ash',             // Active trainer
  appVersion: '1.0.0',        // App version
  device: 'desktop',          // Device type
  features: ['python-editor', 'pokemon-battle']  // Features used
}
```

## Performance Notes

- Heartbeats are sent every 30 seconds (configurable)
- Sessions automatically pause when tab is hidden
- Indexes ensure fast queries even with millions of sessions
- Use `cleanup_abandoned_sessions()` periodically for maintenance

## Privacy & Security

- RLS policies allow users to see all sessions (public app)
- Each user can only create/update their own sessions
- No sensitive data should be stored in metadata
- Sessions can be anonymized by using usernames instead of emails

## Troubleshooting

### Sessions not being created
- Check if username is null or empty
- Verify Supabase connection
- Check browser console for errors

### Heartbeats not updating
- Verify the component using `useUsageSession` stays mounted
- Check network tab for failed requests
- Ensure RLS policies allow updates

### Sessions not ending
- Check if component properly unmounts on logout
- Verify `endSession` is being called
- Use `cleanup_abandoned_sessions()` for stuck sessions

## Example: Display User Stats

```typescript
import { dbHelpers } from './lib/supabase'

function UserStats({ username }: { username: string }) {
  const [stats, setStats] = useState(null)

  useEffect(() => {
    async function loadStats() {
      const { data } = await dbHelpers.getUserSessionStats(username)
      setStats(data)
    }
    loadStats()
  }, [username])

  if (!stats) return <div>Loading...</div>

  return (
    <div>
      <h2>Your Activity Stats</h2>
      <p>Total Sessions: {stats.totalSessions}</p>
      <p>Total Active Time: {stats.totalActiveMinutes} minutes</p>
      <p>Average Session: {stats.averageSessionMinutes} minutes</p>
    </div>
  )
}
```

## Next Steps

- Add charts/graphs for session analytics
- Create leaderboards based on active time
- Track feature-specific usage in metadata
- Set up automated cleanup job with pg_cron
- Export session data for external analytics
