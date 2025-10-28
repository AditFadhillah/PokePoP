# Game-Database Integration Setup Guide

## Overview

Now your Pokémon game is integrated with the Supabase database! Here's how the system works:

## How It Works

### 1. Trainer Selection in React
- Create/select a trainer in the React app
- The trainer name is automatically sent to the Godot game
- The game UI updates to show the correct trainer name

### 2. Pokémon Capture Flow
```
Godot Game (Battle) → React App → Supabase Database
```

When you capture a Pokémon in Godot:
1. **Godot**: Calculates points (level × 100)
2. **Godot**: Sends capture data to React via JSBridge
3. **React**: Receives capture data and saves to Supabase
4. **React**: Updates the trainer's inventory and points
5. **React**: Shows confirmation message

### 3. Database Storage
- Each captured Pokémon is stored with:
  - Trainer ID (links to the current trainer)
  - Pokémon name (BULBASAUR, CATERPIE, EEVEE, PIDGEY, VULPIX)
  - Level (1-3)
  - Points (level × 100)
  - Capture timestamp

## Testing Steps

### Step 1: Set Up Database
1. Run the `database_schema.sql` in your Supabase SQL Editor
2. Make sure the tables are created properly

### Step 2: Start the React App
1. Run `npm run dev` in your project root
2. Open the app in your browser

### Step 3: Create a Trainer
1. Enter a trainer name (e.g., "Ash")
2. Click "Create/Load Trainer"
3. You should see the trainer appear in the React UI
4. The Godot game should automatically update to show the trainer name

### Step 4: Test Pokémon Capture
1. In the Godot game, encounter a wild Pokémon (walk around)
2. Click "CAPTURE" in the battle
3. Check the React app - you should see:
   - The captured Pokémon in the inventory
   - Updated point total
   - Confirmation message in the Python output area

### Step 5: Test Multiple Trainers
1. Click "Switch Trainer" in React
2. Create another trainer (e.g., "Misty")
3. Capture Pokémon with this new trainer
4. Use "Load Leaderboard" to see both trainers

## Pokémon Pool & Points

**Available Pokémon:**
- BULBASAUR
- CATERPIE
- EEVEE
- PIDGEY
- VULPIX

**Levels & Points:**
- Level 1 = 100 points
- Level 2 = 200 points
- Level 3 = 300 points

**Random Generation:**
- Each battle spawns a random Pokémon from the pool
- Each Pokémon has a random level (1-3)

## Message Flow

### Godot → React Messages
```javascript
// Battle started
{ type: 'BATTLE_STARTED', message: 'in battle' }

// Battle ended  
{ type: 'BATTLE_ENDED', message: 'battle ended' }

// Pokémon captured
{ 
  type: 'POKEMON_CAPTURED', 
  pokemon_name: 'PIKACHU',
  level: 2,
  points: 200,
  captured_at: '2025-10-28T...'
}
```

### React → Godot Messages
```javascript
// Trainer selected
{ type: 'TRAINER_SELECTED', trainer_name: 'Ash' }
```

## Warning System

If no trainer is selected in React:
- ⚠️ Warning appears in the React UI
- Pokémon captures are still processed in Godot (local GameManager)
- But they won't be saved to the database
- A warning message appears in the Python output

## Troubleshooting

### Common Issues

1. **Trainer name not updating in game**
   - Make sure you created/loaded a trainer in React
   - Check browser console for JSBridge messages
   - Verify the game is running in web export

2. **Captures not saving to database**
   - Check if a trainer is selected in React
   - Verify Supabase connection (check "Supabase status")
   - Look for error messages in browser console

3. **JSBridge not working**
   - Only works in web export, not in Godot editor
   - Make sure the game is loaded in the React iframe
   - Check browser console for JavaScript errors

### Debug Tips

1. **Check React Console**: Look for "Sent trainer data to game" messages
2. **Check Godot Output**: Look for "Received trainer update from Javascript" messages  
3. **Check Database**: Use Supabase dashboard to verify data is being stored
4. **Test Offline**: The game still works locally even without database connection

## Next Features to Add

1. **Pokémon Sprites**: Show actual Pokémon images in the database
2. **Battle Statistics**: Track wins/losses per trainer
3. **Pokémon Evolution**: Allow Pokémon to evolve based on level
4. **Trading System**: Allow trainers to trade Pokémon
5. **Achievements**: Award badges for milestones

The system is now fully integrated and ready for multi-trainer Pokémon collecting with persistent database storage!