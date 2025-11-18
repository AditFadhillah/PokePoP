# Database Setup Guide for Trainer Creation on Signup

## Overview
This guide will help you set up the connection between `test_username` and `trainers` tables so that new trainers are automatically created when users sign up.

## Step 1: Run the Database Migration

1. Go to your Supabase dashboard: https://mnhbgztpmnesnkeyethm.supabase.co
2. Click on the **SQL Editor** in the left sidebar
3. Click **New Query**
4. Copy and paste the contents of `connect_test_username_to_trainers.sql`
5. Click **Run** to execute the migration

This will:
- Add an `id` UUID column to `test_username` table (if not exists)
- Add a `test_user_id` column to `trainers` table
- Create a foreign key constraint linking trainers to test_username
- Set up RLS policies for public access (INSERT, SELECT, UPDATE)

## Step 2: Verify the Migration

Run this query in the SQL Editor to verify:

```sql
-- Check test_username has id column
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'test_username';

-- Check trainers has test_user_id column
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'trainers';

-- Check foreign key constraint
SELECT
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND tc.table_name='trainers';
```

## Step 3: Test the Signup Flow

1. Start your development server:
   ```bash
   npm run dev
   ```

2. Navigate to the signup page
3. Create a new account with:
   - Username: `testuser1`
   - Password: `password123`
   - Confirm Password: `password123`

4. After signup, verify in Supabase:
   ```sql
   -- Check the new user was created
   SELECT * FROM test_username WHERE username = 'testuser1';
   
   -- Check the trainer was created (get the id from above query)
   SELECT * FROM trainers WHERE test_user_id = '<id-from-above>';
   ```

## Step 4: Update Existing Trainers (Optional)

If you have existing trainers that need to be linked to test_username users, you'll need to manually map them:

```sql
-- Example: Link existing trainer to test_username user
UPDATE trainers 
SET test_user_id = (SELECT id FROM test_username WHERE username = 'player1')
WHERE name = 'Player One';
```

## Troubleshooting

### Issue: "Column test_user_id does not exist"
**Solution**: Make sure you ran the migration script in Step 1.

### Issue: "Duplicate key violation"
**Solution**: The username already exists. Try a different username.

### Issue: "Foreign key constraint violation"
**Solution**: The test_username insert failed. Check the error message for details.

### Issue: "Permission denied for table trainers"
**Solution**: RLS policies may not be set correctly. Rerun the RLS policy section of the migration script.

## Current Flow

1. User fills out signup form (username, password, confirm password)
2. Frontend validates passwords match
3. Frontend inserts into `test_username` table and gets back the new user ID
4. Frontend inserts into `trainers` table with:
   - `test_user_id`: The new user's ID
   - `name`: The username
   - `total_points`: 0 (starting points)
5. User is automatically logged in and redirected to dashboard

## Next Steps

After successful setup, you may want to:

1. **Filter Trainers by User**: Update `App.tsx` to load only the logged-in user's trainers
2. **Add Trainer Selection**: Allow users to manage multiple trainers
3. **Secure RLS Policies**: Change from public access to user-specific policies:
   ```sql
   -- Example: Users can only see their own trainers
   CREATE POLICY "Users can view own trainers"
   ON trainers FOR SELECT
   USING (test_user_id = auth.uid());
   ```
4. **Add Username Uniqueness**: Ensure no duplicate usernames (already handled by error checking)
