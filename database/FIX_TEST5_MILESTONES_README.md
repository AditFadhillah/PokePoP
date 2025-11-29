# Fix for test5 Milestones Not Showing

## Problem Diagnosis

The milestones modal for test5 shows "No milestones unlocked yet" even though test5 has captured Pokemon.

### Root Cause

There's a **user ID mismatch** between the frontend and database:

1. **Frontend (MilestonesModal.tsx)**:
   - Receives `userId` from `currentAppUser?.id`
   - `currentAppUser` comes from the `test_username` table
   - So it passes `test_username.id` to the database function

2. **Database (user_achievements table)**:
   - The `user_achievements.user_id` field may reference `auth.users.id` instead of `test_username.id`
   - Or the link between `test_username` and `trainers` may not be properly set via `test_user_id`

3. **Database Function (get_user_achievements)**:
   - Queries `user_achievements` WHERE `user_id = p_user_id`
   - If the IDs don't match, no achievements are returned

## Solution

### Step 1: Run the Diagnostic Script

Run `database/diagnose_test5_user_id_mismatch.sql` in Supabase SQL Editor to identify the exact issue.

### Step 2: Run the Comprehensive Fix

Run `database/fix_test5_milestones.sql` in Supabase SQL Editor. This script will:

1. ✅ Create an alternative function `get_user_achievements_by_test_user()` that works with `test_username.id`
2. ✅ Update the original `get_user_achievements()` function to handle BOTH `auth.users.id` AND `test_username.id`
3. ✅ Check if test5's trainer is properly linked via `test_user_id`
4. ✅ Backfill any missing achievements for test5 based on their stats
5. ✅ Verify the achievements are properly stored and retrievable

### Step 3: Run the Backfill Script (if needed)

If test5 has captured Pokemon but has no achievements, run `database/check_test5_achievements.sql` to:

1. Check test5's stats and Pokemon captures
2. Identify which achievements they should have
3. Automatically award those achievements
4. Update their achievement points

### Step 4: Test in the Application

1. Login as test5
2. Click the "Milestones" button
3. The modal should now show their unlocked achievements
4. Check the browser console for debug logs:
   ```
   🔍 MilestonesModal: Loading achievements for userId: <uuid>
   ✅ MilestonesModal: Loaded X achievements
   ```

## Files Modified

### Frontend
- **src/views/MilestonesModal.tsx**
  - Added console logging to debug the achievement loading process
  - Logs the userId being passed and the number of achievements returned

### Database Scripts Created
1. **database/diagnose_test5_user_id_mismatch.sql**
   - Comprehensive diagnostic script to identify the ID mismatch issue

2. **database/fix_test5_milestones.sql**
   - Updates `get_user_achievements()` function to handle both ID types
   - Creates alternative function for test_username users
   - Backfills missing achievements for test5
   - Includes verification queries

3. **database/check_test5_achievements.sql**
   - Checks test5's current state
   - Identifies missing achievements
   - Backfills them using `check_and_award_achievements()`

### Database Schema (Existing)
The `trainers` table should have both:
- `user_id` → references `auth.users.id` (for Supabase Auth users)
- `test_user_id` → references `test_username.id` (for simple username/password auth)

## Expected Behavior After Fix

1. ✅ test5 can see their milestones when clicking the Milestones button
2. ✅ All past achievements are backfilled based on their capture history
3. ✅ Future achievements will be automatically awarded when captured
4. ✅ The MilestonesModal works for BOTH auth.users and test_username users

## Verification

After running the fix scripts, verify with these queries:

```sql
-- Check test5's achievements
SELECT 
    tu.username,
    COUNT(ua.id) as achievement_count,
    SUM(a.points) as total_achievement_points
FROM test_username tu
JOIN trainers t ON t.test_user_id = tu.id
LEFT JOIN user_achievements ua ON ua.trainer_id = t.id
LEFT JOIN achievements a ON a.id = ua.achievement_id
WHERE tu.username = 'test5'
GROUP BY tu.username;

-- Test the function
SELECT * FROM get_user_achievements(
    (SELECT id FROM test_username WHERE username = 'test5')
);
```

## Additional Notes

- The system supports TWO types of authentication:
  1. **Supabase Auth** (`auth.users`) - full OAuth authentication
  2. **Simple Auth** (`test_username`) - username/password for testing
  
- The `get_user_achievements()` function now works with BOTH types

- The `user_achievements` table links achievements via `trainer_id`, which is connected to users via the `trainers` table

## Troubleshooting

If milestones still don't show after the fix:

1. Check browser console for error messages
2. Verify test5 is logged in (check `currentAppUser` in React DevTools)
3. Run the diagnostic script to check database state
4. Verify `trainers.test_user_id` is properly set for test5's trainer
5. Check if `user_stats` exists for test5 (required for achievements)
