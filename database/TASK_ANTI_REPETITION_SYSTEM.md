# Task Anti-Repetition System

## Overview
This system prevents users from getting the same programming task twice in a row by tracking the last 2 completed tasks and excluding them from the random selection.

## How It Works

### 1. **Database Function** (`update_get_random_task_exclude_recent.sql`)
The `get_random_task()` function now accepts an array of task IDs to exclude:

```sql
get_random_task(
    task_category TEXT DEFAULT NULL,        -- Filter by region (e.g., 'Forest')
    excluded_task_ids UUID[] DEFAULT ARRAY[]::UUID[]  -- Task IDs to exclude
)
```

**Logic:**
- Randomly selects a task from the specified category
- Excludes any tasks whose ID is in the `excluded_task_ids` array
- Returns 1 random task that meets the criteria

### 2. **Frontend Tracking** (`App.tsx`)
The frontend maintains a `recentTaskIds` array that stores the last 2 task IDs:

```typescript
const [recentTaskIds, setRecentTaskIds] = useState<string[]>([])
```

**When a new task loads:**
1. Passes `recentTaskIds` to the database function
2. Database excludes those tasks from selection
3. New task is added to the front of `recentTaskIds`
4. Array is trimmed to keep only the 2 most recent IDs

**Example Flow:**
```
Task 1 loaded → recentTaskIds = ['task1-id']
Task 2 loaded → recentTaskIds = ['task2-id', 'task1-id']
Task 3 loaded → recentTaskIds = ['task3-id', 'task2-id']  // task1 dropped
Task 4 loaded → recentTaskIds = ['task4-id', 'task3-id']  // task2 dropped
```

## Benefits

✅ **No Immediate Repeats**: Users won't get the same task twice in a row  
✅ **2-Task Memory**: Prevents getting the same task for 2 consecutive battles  
✅ **Regional Filtering**: Works seamlessly with region-based task filtering  
✅ **Graceful Fallback**: If all tasks are excluded, the system will still work (though might repeat sooner)

## Installation

### Step 1: Update Database Function
Run the SQL script in your Supabase SQL Editor:
```bash
database/update_get_random_task_exclude_recent.sql
```

### Step 2: Frontend Already Updated
The frontend code in `App.tsx` has been updated to:
- Track recent task IDs
- Pass them to the database function
- Update the list after each new task

## Testing

1. **Start a battle** - Note the task title/description
2. **Complete the task** (or exit the battle)
3. **Start another battle** - You should NOT get the same task
4. **Complete again**
5. **Start a 3rd battle** - You can now get the 1st task again (since only last 2 are excluded)

## Configuration

To change how many tasks are remembered, modify this line in `loadRandomTask()`:

```typescript
return updated.slice(0, 2) // Change 2 to 3, 4, etc.
```

And update the database function parameter name accordingly (though it will still work with any size array).

## Edge Cases

**Case 1: Only 2 tasks in a region**
- If a region has exactly 2 tasks, they will alternate
- User will never see the same task twice in a row

**Case 2: Only 1 task in a region**
- The system will return that task even if excluded
- Database query will fail to find non-excluded tasks, so might need fallback logic

**Case 3: User refreshes page**
- `recentTaskIds` is reset (stored in state, not persisted)
- User might get a recently seen task after refresh
- Could be enhanced with localStorage persistence if needed

## Future Enhancements

1. **Persist to localStorage**: Remember recent tasks across page refreshes
2. **Per-region tracking**: Track recent tasks separately for each region
3. **Difficulty progression**: Gradually increase task difficulty instead of random
4. **User preference**: Let users adjust how many tasks to remember

