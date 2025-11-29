# Quick Fix Checklist - New User Signup Errors

## The Problem
New users (like test6) got these errors:
- ❌ 404: login_events table not found
- ❌ 404: compute_login_streak function not found
- ❌ 406: user_stats query blocked by RLS

## The Solution (2 Steps)

### Step 1: Run Database Fix ⚡
Open Supabase SQL Editor and run:
```
database/FIX_NEW_USER_SIGNUP_ERRORS.sql
```

This fixes the RLS policies so test_username users can access user_stats and user_achievements.

### Step 2: Rebuild/Restart Frontend 🔄
Frontend code is already fixed, just apply it:
```bash
npm run dev
```
Or if already running, just refresh the page.

## That's It! ✅

Test by:
1. Create a new account (test7, test8, etc.)
2. Should see NO errors in console
3. After capturing first Pokemon, check Milestones - should show 2 achievements

## What Was Fixed

### Frontend (Already Applied)
- ✅ Removed calls to non-existent login_events table
- ✅ Removed calls to non-existent compute_login_streak function
- ✅ Added proper initializeUserStats() and updateLoginStreak() calls
- ✅ Fixed trainer creation to use test_user_id instead of user_id

### Database (Run SQL Script)
- ✅ Fixed RLS policies to allow test_username users
- ✅ Both user_stats and user_achievements now accessible

## Expected Result

**Before Fix:**
```
❌ POST .../login_events 404 (Not Found)
❌ POST .../compute_login_streak 404 (Not Found)
❌ GET .../user_stats 406 (Not Acceptable)
```

**After Fix:**
```
✅ 🟢 Starting usage session for: test7
✅ Usage session started
✅ MilestonesModal: Loaded 0 achievements (new user)
```

After first capture:
```
✅ MilestonesModal: Loaded 2 achievements
   - First Catch!
   - Dedicated Trainer
```

## Files Modified
- `src/App.tsx` - Fixed signup handler
- `src/views/signupView.tsx` - Fixed trainer creation
- `database/FIX_NEW_USER_SIGNUP_ERRORS.sql` - Database fix script

All done! 🎉
