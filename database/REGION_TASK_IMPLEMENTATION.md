# Region-Based Task System Implementation Guide

This guide explains how to implement region-specific programming tasks in PokePoP.

## Overview
The game has 4 regions, each with specific Pokemon and programming task categories:
- **Forest**: Basic Loops (6 tasks)
- **Beach**: Dictionaries (7 tasks) 
- **Volcano**: Regex (6 tasks)
- **Swamp**: Advanced/Tuples (5 tasks)

## Implementation Steps

### 1. Database Setup

Run these SQL scripts in order in your Supabase SQL Editor:

#### Step 1: Add category column
```bash
database/add_category_to_tasks.sql
```

#### Step 2: Update the get_random_task function
```bash
database/update_get_random_task_with_category.sql
```

### 2. Game Code Changes

#### battle.gd (Line 286-291)
Update the BATTLE_STARTED message to include region:

```gdscript
if JSBridge:
    JSBridge.send_message_to_react("BATTLE_STARTED", {
        "message": "in battle",
        "pokemon_name": current_pokemon,
        "pokemon_level": enemy.current_pokemon_level,
        "region": current_region  # ADD THIS LINE
    })
```

### 3. React App Changes

#### App.tsx

##### Update the loadRandomTask function (around line 577):
```typescript
async function loadRandomTask(region: string | null = null) {
  try {
    console.log('Loading random task for region:', region)
    const { data, error } = await supabase
      .rpc('get_random_task', { task_category: region })
    
    console.log('Task data:', data)
    console.log('Task error:', error)
    
    if (error) {
      console.error('Error loading task:', error)
      setOutput(`❌ Failed to load programming task: ${error.message || 'Unknown error'}`)
      setIsTaskActive(false)
      return
    }
    
    if (data && data.length > 0) {
      const task = data[0]
      console.log('Task loaded:', task)
      setCurrentTask(task)
      setCode(task.starter_code || '')
      setOutput(`📍 Region: ${region || 'Any'} - Category: ${task.category || 'General'}\n\nTask: ${task.title}\n\n${task.description}\n\nSolve this task to capture the Pokemon!`)
    } else {
      console.warn('No tasks found in database for region:', region)
      setOutput('❌ No tasks available for this region.')
      setIsTaskActive(false)
    }
  } catch (error: any) {
    console.error('Error loading task:', error)
    setOutput(`❌ Failed to load programming task: ${error.message || 'Unknown error'}`)
    setIsTaskActive(false)
  }
}
```

##### Update the battle started handler (around line 373-375):
```typescript
if (data.message === "BATTLE_STARTED") {
  console.log('Received BATTLE_STARTED event from Godot:', data)
  setIsTaskActive(true)
  taskCompletionSentRef.current = false
  // Pass the region from the battle data
  loadRandomTask(data.region || null)
}
```

## Task Distribution by Region

### Forest Region (Basic Loops) - 6 tasks
1. Count Vowels in String
2. Sum List with Loop
3. Nested Loop Pattern  
4. Find Even Numbers
5. Nested Loop Sum
6. Loop Through Dictionary

### Beach Region (Dictionaries) - 7 tasks
1. Dictionary Key Check
2. Reverse Dictionary
3. Count Words in Dictionary
4. Dictionary Merge
5. Dictionary from Two Lists
6. Get Dictionary Keys
7. Nested Dictionary Access

### Volcano Region (Regex) - 6 tasks
1. Find Email Pattern
2. Extract Phone Numbers
3. Replace Digits
4. Validate Username
5. Split by Pattern
6. Find Hashtags

### Swamp Region (Advanced/Tuples) - 5 tasks
1. Multiplication Table
2. Tuple Unpacking
3. Tuple to Lowercase List
4. Reverse Dictionary (zodiac)
5. DNA to mRNA Transcription

## Testing

After implementing all changes:

1. **Test Database Functions:**
```sql
-- Should return a Forest-region task (loops)
SELECT * FROM get_random_task('Forest');

-- Should return a Beach-region task (dictionaries)
SELECT * FROM get_random_task('Beach');

-- Should return a Volcano-region task (regex)
SELECT * FROM get_random_task('Volcano');

-- Should return a Swamp-region task (tuples/advanced)
SELECT * FROM get_random_task('Swamp');

-- Should return any random task
SELECT * FROM get_random_task();
```

2. **Test In-Game:**
- Enter each region (Forest, Beach, Volcano, Swamp)
- Trigger a battle in each region
- Verify you get tasks from the corresponding category
- Forest should give loop tasks
- Beach should give dictionary tasks
- Volcano should give regex tasks
- Swamp should give tuple/advanced tasks

## Verification

Check that the categorization is correct:
```sql
SELECT 
    category,
    COUNT(*) as task_count,
    string_agg(title, ', ' ORDER BY title) as tasks
FROM public.programming_tasks
GROUP BY category
ORDER BY category;
```

Expected results:
- Beach: 7 tasks
- Forest: 6 tasks
- Swamp: 5 tasks
- Volcano: 6 tasks

Total: 24 tasks
