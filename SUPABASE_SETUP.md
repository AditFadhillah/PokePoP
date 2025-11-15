# Supabase Database Setup Guide

This guide will help you set up your Supabase database for the PokePoP application.

## Prerequisites

- ✅ Supabase account created
- ✅ Supabase project created
- ✅ Environment variables set in `.env` file

## Setup Steps

### Step 1: Run the Database Schema

1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Click on **SQL Editor** in the left sidebar
4. Click **New Query**
5. Copy the entire content of `database_schema.sql`
6. Paste it into the SQL Editor
7. Click **Run** (or press Ctrl+Enter)

This will create:
- ✅ `trainers` table
- ✅ `pokemon_inventory` table
- ✅ Indexes for performance
- ✅ Row Level Security (RLS) policies
- ✅ Automatic triggers to update points
- ✅ `trainer_leaderboard` view

### Step 2: Import Your CSV Data (Optional)

If you want to import the test data from your CSV files:

1. In the SQL Editor, create a **New Query**
2. Copy the content of `migrate_csv_to_supabase.sql`
3. **IMPORTANT**: Before running, you need to get your user ID:
   - Run this query first: `SELECT id FROM auth.users LIMIT 1;`
   - Copy the UUID that's returned
4. The migration script will use your authenticated user ID automatically
5. Click **Run**

This will populate your database with:
- 3 trainers (B, Ash, tester)
- 11 Pokemon entries

### Step 3: Verify Your Tables

Go to **Table Editor** in Supabase:

1. Check the `trainers` table - you should see your trainers
2. Check the `pokemon_inventory` table - you should see Pokemon entries
3. Verify that `total_points` matches the sum of Pokemon points for each trainer

### Step 4: Test Authentication (If Needed)

If you're using authentication:

1. Go to **Authentication** → **Users** in Supabase
2. Create a test user or use your existing user
3. The trainer data will be associated with this user

### Alternative: Disable RLS for Testing

If you want to test without authentication:

```sql
-- Temporarily disable RLS (NOT recommended for production)
ALTER TABLE public.trainers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pokemon_inventory DISABLE ROW LEVEL SECURITY;
```

**Remember to re-enable RLS before deploying to production!**

## Database Structure

### `trainers` table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key (auto-generated) |
| user_id | UUID | Reference to auth.users |
| name | TEXT | Trainer name |
| total_points | INTEGER | Total points from all Pokemon |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |

### `pokemon_inventory` table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key (auto-generated) |
| trainer_id | UUID | Reference to trainers.id |
| pokemon_name | TEXT | Pokemon name (e.g., "PIKACHU") |
| level | INTEGER | Pokemon level (1-100) |
| points | INTEGER | Points awarded for capture |
| captured_at | TIMESTAMPTZ | Capture timestamp |

## Quick Manual Data Entry

If you prefer to manually add trainers through the Table Editor:

1. Go to **Table Editor** → **trainers**
2. Click **Insert** → **Insert row**
3. Fill in:
   - `user_id`: Your user UUID from auth.users
   - `name`: Trainer name (e.g., "Ash")
   - `total_points`: 0 (will auto-update)
4. Click **Save**

To add Pokemon:

1. Go to **Table Editor** → **pokemon_inventory**
2. Click **Insert** → **Insert row**
3. Fill in:
   - `trainer_id`: The UUID of the trainer
   - `pokemon_name`: Pokemon name (e.g., "PIKACHU")
   - `level`: 1-100
   - `points`: Point value
4. Click **Save**

The `total_points` in the trainers table will automatically update!

## Troubleshooting

### Error: "No authenticated user"
- Make sure you're logged into Supabase when running SQL queries
- Or temporarily disable RLS for testing

### Error: "Permission denied"
- Check that your RLS policies are set up correctly
- Verify you're using the correct user_id

### Pokemon not showing up
- Verify the `trainer_id` in pokemon_inventory matches an existing trainer's `id`
- Check the SQL join in your queries

### Points not updating
- Check that the triggers were created successfully
- Run: `SELECT * FROM pg_trigger WHERE tgname LIKE '%trainer_points%';`

## Useful Queries

### View all trainers with Pokemon count
```sql
SELECT * FROM trainer_leaderboard;
```

### View a specific trainer's Pokemon
```sql
SELECT * FROM pokemon_inventory 
WHERE trainer_id = 'YOUR-TRAINER-UUID-HERE';
```

### Calculate total points manually
```sql
SELECT 
    t.name,
    t.total_points as recorded,
    SUM(pi.points) as calculated
FROM trainers t
LEFT JOIN pokemon_inventory pi ON t.id = pi.trainer_id
GROUP BY t.id, t.name, t.total_points;
```

## Next Steps

After setting up the database:
1. ✅ Make sure your `.env` file has the correct Supabase credentials
2. ✅ Run `npm run dev` to start your application
3. ✅ Click on a trainer button to load their data
4. ✅ Play the game and capture Pokemon - they'll save automatically!

Your data is now stored in Supabase and will persist across sessions! 🎮✨
