# Region Achievement System - UNIQUE Pokemon Tracking

## Problem Identified

You correctly identified a major flaw in the original system:

**Old System (BROKEN):**
- Counted total captures per region (e.g., `forest_captures = 17`)
- Would award "Forest Master" achievement even if you caught 17 RATTATA
- Rare Pokemon counted toward region completion even though they can appear anywhere

**Why This is Wrong:**
- Region mastery should require catching all 6 UNIQUE Pokemon from that region
- Rare Pokemon (VAPOREON, JOLTEON, FLAREON, DITTO, MEW, PIKACHU_) can appear in any region and shouldn't count

## New System (FIXED)

### Pokemon Region Mapping

Each region has 6 specific Pokemon:

**Forest Region:**
1. RATTATA
2. CATERPIE
3. EEVEE
4. VULPIX
5. BULBASAUR
6. PIDGEY

**Beach Region:**
1. SQUIRTLE
2. HORSEA
3. MEOWTH
4. KRABBY
5. SEEL
6. MAGIKARP

**Volcano Region:**
1. CHARMANDER
2. DIGLETT
3. CUBONE
4. RHYHORN
5. PONYTA
6. GEODUDE

**Swamp Region:**
1. GRIMER
2. GASTLY
3. ODDISH
4. ZUBAT
5. VENONAT
6. EKANS

**Rare Pokemon (Don't count for region completion):**
- VAPOREON, JOLTEON, FLAREON, DITTO, MEW, PIKACHU_
- These can appear in any region with 5% probability
- They're collectible but don't contribute to regional mastery

### How It Works

1. **pokemon_regions table**: Defines which Pokemon belong to which region
2. **get_unique_pokemon_by_region() function**: Counts DISTINCT Pokemon names per region for a trainer
3. **Updated check_and_award_achievements()**: Uses unique counts instead of simple totals
4. **trainer_region_progress view**: Shows exactly which Pokemon each trainer has/needs

### Example Scenarios

**Scenario 1: 17 Rattata (OLD SYSTEM = WRONG)**
```
Old: forest_captures = 17 → ❌ Awards Forest Master (WRONG!)
New: forest_unique = 1 (only RATTATA) → ✓ No achievement (CORRECT!)
```

**Scenario 2: All Forest Pokemon (CORRECT)**
```
Captured: RATTATA, CATERPIE, EEVEE, VULPIX, BULBASAUR, PIDGEY
New: forest_unique = 6 → ✓ Awards Forest Master (CORRECT!)
```

**Scenario 3: Rare Pokemon Don't Count**
```
Captured: RATTATA, CATERPIE, EEVEE, VULPIX, BULBASAUR, PIKACHU_
New: forest_unique = 5 (PIKACHU_ excluded) → ✓ No achievement (CORRECT!)
```

## Implementation Details

### Database Changes

1. **New Table: pokemon_regions**
   - Stores Pokemon-to-region mappings
   - Marks rare Pokemon with `is_rare = TRUE`
   
2. **New Function: get_unique_pokemon_by_region()**
   - Returns unique Pokemon count per region for a trainer
   - Excludes rare Pokemon
   - Returns list of captured Pokemon names

3. **Updated Function: check_and_award_achievements()**
   - Now queries unique counts instead of simple totals
   - Checks: forest_unique >= 6, beach_unique >= 6, etc.
   - More accurate achievement detection

4. **New View: trainer_region_progress**
   - Shows progress for all trainers
   - Lists exactly which Pokemon are captured
   - Shows X/6 completion for each region

### Verification Queries

```sql
-- See your region progress
SELECT * FROM trainer_region_progress 
WHERE trainer_id = 'YOUR_TRAINER_ID';

-- See which Pokemon you're missing
SELECT pr.region, pr.pokemon_name,
    CASE WHEN pi.id IS NOT NULL THEN '✓' ELSE '✗' END AS status
FROM pokemon_regions pr
LEFT JOIN pokemon_inventory pi ON 
    pr.pokemon_name = pi.pokemon_name AND 
    pi.trainer_id = 'YOUR_TRAINER_ID'
WHERE pr.is_rare = FALSE
ORDER BY pr.region, pr.pokemon_name;
```

## For Test1 User

After running the script, you can check:

```sql
-- Your unique Pokemon per region
SELECT * FROM get_unique_pokemon_by_region('f362f578-c144-4f1a-8142-8840b206e8c8');

-- Your region completion status
SELECT * FROM trainer_region_progress 
WHERE trainer_id = 'f362f578-c144-4f1a-8142-8840b206e8c8';

-- Which Pokemon you still need
SELECT region, pokemon_name, status
FROM (
    SELECT pr.region, pr.pokemon_name,
        CASE WHEN pi.id IS NOT NULL THEN '✓ Captured' ELSE '✗ Need to capture' END AS status
    FROM pokemon_regions pr
    LEFT JOIN pokemon_inventory pi ON 
        pr.pokemon_name = pi.pokemon_name AND 
        pi.trainer_id = 'f362f578-c144-4f1a-8142-8840b206e8c8'
    WHERE pr.is_rare = FALSE
) sub
ORDER BY region, pokemon_name;
```

## Achievement Points Updated

All achievements now have meaningful points (minimum 100):

- Capture milestones: 100-400 points
- Region completion: 500 points each
- Login streaks: 50-200 points
- Duration: 250-1000 points

## How to Apply

1. Run `fix_region_achievement_unique_pokemon.sql` in Supabase SQL Editor
2. Script will:
   - Create pokemon_regions table
   - Update achievement checking logic
   - Re-award achievements based on correct unique Pokemon counts
   - Show verification results
3. Check the output to see your actual region progress

## Expected Result for Test1

Based on your captures, test1 has:
- **Forest**: RATTATA, CATERPIE, EEVEE, VULPIX, BULBASAUR, PIDGEY = 6/6 ✓
- **Beach**: MEOWTH, KRABBY = 2/6 ✗
- **Volcano**: CHARMANDER, GEODUDE = 2/6 ✗
- **Swamp**: ODDISH, EKANS, GASTLY, ZUBAT, VENONAT = 5/6 ✗

So test1 should receive:
- ✅ **Forest Master** achievement (500 points)
- ✗ Other region achievements (not yet complete)
