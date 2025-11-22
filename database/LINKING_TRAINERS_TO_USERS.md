# Setup Instructions: Link Existing Trainers to User Accounts

## Step 1: Run the Database Migration

First, make sure you've run `connect_test_username_to_trainers.sql` to set up the foreign key relationship.

## Step 2: Create User Accounts for Existing Trainers

Run `link_existing_trainers_to_users.sql` in your Supabase SQL Editor. This will:

1. Create two user accounts:
   - Username: `trainer1`, Password: `password1`
   - Username: `trainer2`, Password: `password2`

2. Link the existing trainers to these accounts:
   - Trainer "trainer1" → user "trainer1"
   - Trainer "trainer2" → user "trainer2"

3. Display verification results

## Step 3: Test the Login Flow

1. **Login as trainer1:**
   - Username: `trainer1`
   - Password: `password1`
   - Expected: Automatically selects trainer1 and loads their Pokemon

2. **Login as trainer2:**
   - Username: `trainer2`
   - Password: `password2`
   - Expected: Automatically selects trainer2 and loads their Pokemon

3. **Create new account:**
   - Sign up with a new username
   - Expected: New user and trainer created automatically
   - Expected: Trainer auto-selected after signup

## What Changed

### Database Changes
- Added `user_id` column to `trainers` table (links to `test_username.id`)
- Created user accounts for existing trainers
- Linked existing trainers to their user accounts

### App.tsx Changes
1. **`loadTrainers()` function**: Now accepts optional `userId` parameter to filter trainers by user
2. **`handleLoginSubmit()` function**: Automatically loads and selects user's trainer after login
3. **Signup success handler**: Automatically loads and selects newly created trainer after signup

## User Experience

### Before Login:
- User sees welcome screen
- Can login, signup, or play as guest

### After Login:
- User's trainer is **automatically selected**
- Pokemon inventory is loaded
- Trainer name and stats are displayed
- Ready to play immediately

### After Signup:
- New user account created
- New trainer created with username as trainer name
- Trainer **automatically selected**
- Ready to play immediately

## Security Note

⚠️ **IMPORTANT**: The passwords are stored in plain text for simplicity. For production, you should:
1. Hash passwords using bcrypt or similar
2. Use Supabase Auth instead of custom authentication
3. Implement proper RLS policies that filter by authenticated user

## Trainer Selection Buttons

The "Trainer 1" and "Trainer 2" buttons in the UI will now only show trainers that belong to the logged-in user. If playing as guest, it shows all trainers.

## Future Enhancements

- Allow users to create multiple trainers
- Add trainer selection screen after login
- Add "Create New Trainer" button
- Implement trainer switching during gameplay
