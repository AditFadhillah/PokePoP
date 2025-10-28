# PokePoP Multi-Trainer Database Setup

This guide explains how to set up and use the multi-trainer Pokémon inventory system with Supabase.

## Database Setup

### 1. Run the Database Schema

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy and paste the contents of `database_schema.sql`
4. Click "Run" to execute the SQL commands

This will create:
- `trainers` table - stores trainer information
- `pokemon_inventory` table - stores each trainer's Pokémon
- Proper indexes for performance
- Row Level Security (RLS) policies
- Automatic triggers to update trainer points
- A leaderboard view

### 2. Database Structure

#### Trainers Table
```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key to auth.users)
- name (TEXT, Trainer name)
- total_points (INTEGER, Auto-calculated)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### Pokemon Inventory Table
```sql
- id (UUID, Primary Key)
- trainer_id (UUID, Foreign Key to trainers)
- pokemon_name (TEXT, Name of the Pokémon)
- level (INTEGER, 1-100)
- points (INTEGER, Points earned)
- captured_at (TIMESTAMP)
```

## How to Use

### 1. Frontend Features

The updated App.tsx now includes:

- **Trainer Creation/Selection**: Enter a trainer name to create or load an existing trainer
- **Pokémon Management**: Add test Pokémon to see the system in action
- **Inventory Display**: View all Pokémon for the current trainer
- **Leaderboard**: See top trainers by points
- **Real-time Updates**: Points automatically update when Pokémon are added

### 2. Testing the System

1. **Create a Trainer**:
   - Enter a trainer name (e.g., "Ash")
   - Click "Create/Load Trainer"

2. **Add Test Pokémon**:
   - Click "Add Test Pokémon" to add random Pokémon
   - Watch points update automatically

3. **Switch Trainers**:
   - Click "Switch Trainer"
   - Create another trainer (e.g., "Misty")
   - Add different Pokémon to see separate inventories

4. **View Leaderboard**:
   - Click "Load Leaderboard" to see all trainers ranked by points

### 3. Integration with Godot Game

To integrate this with your Godot game, you can:

1. **Send Pokémon Capture Data**: When a Pokémon is captured in Godot, send data to the React app
2. **Update Database**: Use the `addPokemonToInventory` function to store captures
3. **Sync Game State**: Keep the game's trainer system in sync with the database

Example integration:
```typescript
// In your message handler for Godot
if (data.type === 'POKEMON_CAPTURED') {
  const { name, level, points } = data.pokemon
  if (currentTrainer) {
    await addPokemonToInventory(currentTrainer.id, { name, level, points })
  }
}
```

## Security Features

- **Row Level Security**: Users can only access their own trainer data
- **Authentication**: All operations require authentication
- **Data Validation**: Database constraints ensure data integrity
- **Automatic Updates**: Triggers keep trainer points in sync

## API Functions Available

The following functions are available in your React app:

- `createOrGetTrainer(name)` - Create or load a trainer
- `loadTrainerInventory(trainerId)` - Load Pokémon inventory
- `addPokemonToInventory(trainerId, pokemonData)` - Add new Pokémon
- `loadAllTrainers()` - Get leaderboard data
- `updateTrainerPoints(trainerId, points)` - Update total points

## Database Queries You Can Run

### Get Top 10 Trainers
```sql
SELECT * FROM trainer_leaderboard LIMIT 10;
```

### Get All Pokémon for a Trainer
```sql
SELECT * FROM pokemon_inventory 
WHERE trainer_id = 'trainer-uuid-here'
ORDER BY captured_at DESC;
```

### Get Trainer Statistics
```sql
SELECT 
  name,
  total_points,
  (SELECT COUNT(*) FROM pokemon_inventory WHERE trainer_id = trainers.id) as pokemon_count
FROM trainers
ORDER BY total_points DESC;
```

## Next Steps

1. **Run the database schema** in Supabase SQL Editor
2. **Test the frontend** by creating trainers and adding Pokémon
3. **Integrate with Godot** by sending capture events to the React app
4. **Customize the UI** to match your game's design
5. **Add more features** like Pokémon stats, evolution tracking, etc.

## Troubleshooting

- **Permission Errors**: Make sure RLS policies are properly set up
- **Connection Issues**: Check your Supabase URL and anon key in `.env`
- **Data Not Showing**: Verify that the user is authenticated
- **Points Not Updating**: Check that the database triggers are working

The system is now ready for multiple trainers with separate Pokémon inventories and a competitive leaderboard system!