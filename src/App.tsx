import { useState, useEffect, useRef } from 'react'
import './App.css'
import { usePyodide } from './lib/usepyodide'
import { supabase, dbHelpers } from './lib/supabase'
// import { supabase as supabaseAuth } from './lib/databaseFunctions'
import { useUsageSession } from './lib/useUsageSession'
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter'
import { vscDarkPlus } from 'react-syntax-highlighter/dist/esm/styles/prism'
import { updateCaptureStats, initializeUserStats, updateLoginStreak, updateSessionDuration } from './lib/achievementHelpers'

// Import neurogen login views and components
import WelcomeView from './views/welcomeView'
import SignupView from './views/signupView'
import DashboardView from './views/dashboardView'
import LoginModal from './components/loginmodal'
import ExamplesModal from './views/ExamplesModal'
import ReferencesModal from './views/ReferencesModal'
import MilestonesModal from './views/MilestonesModal'

function App() {
  // Python Editor States
  const [pyodide, setPyodide] = useState<any>(null)
  const [code, setCode] = useState(`# PyMon Creature Collector
# 
# HOW TO PLAY:
# 1. Move around the map using ARROW KEYS or WASD
# 2. Walk through unique grass to encounter Pokemon
# 3. When a battle starts, solve the Python programming task
# 4. Click "Evaluate Code" to check your solution
# 5. If correct, you capture the Pokemon!
# 6. Collect all Pokemon and become the ultimate trainer!
#
# Press ENTER in the game to start exploring!

print("Ready to start your adventure!")`)
  const [output, setOutput] = useState('')
  const [gameStatus, setGameStatus] = useState('menu') // 'menu', 'battle', 'unknown'

  // Trainer/Pokemon Inventory States
  const [currentTrainer, setCurrentTrainer] = useState<any>(null)
  const currentTrainerRef = useRef<any>(null)
  const [pokemonInventory, setPokemonInventory] = useState<any[]>([])
  // const [totalPoints, setTotalPoints] = useState(0)
  const [, setTotalPoints] = useState(0)
  const [, setAllTrainers] = useState<any[]>([])
  // const [allTrainers, setAllTrainers] = useState<any[]>([])
  // const [isAuthenticated, setIsAuthenticated] = useState(false)

  // App-level user (username/password stored in app_users table)
  const [currentAppUser, setCurrentAppUser] = useState<any>(null)
  const currentAppUserRef = useRef<any>(null)

  // Login modal + auth fields (username-based)
  const [showLogin, setShowLogin] = useState(false)
  const [loginUsername, setLoginUsername] = useState('')
  const [loginPassword, setLoginPassword] = useState('')
  const [authMessage, setAuthMessage] = useState<string | null>(null)
  const [authBusy, setAuthBusy] = useState(false)

  // Simple app view flow: 'welcome' -> 'dashboard' -> 'main'
  const [appView, setAppView] = useState<'welcome' | 'dashboard' | 'main' | 'signup'>('welcome')

  // Programming Task States
  const [currentTask, setCurrentTask] = useState<any>(null)
  // const [taskOutput, setTaskOutput] = useState<string>('')
  const [, setTaskOutput] = useState<string>('')
  const [isTaskActive, setIsTaskActive] = useState(false)
  // const [currentBattlePokemon, setCurrentBattlePokemon] = useState<any>(null)
  const [, setCurrentBattlePokemon] = useState<any>(null)
  const taskCompletionSentRef = useRef(false)

  // Leaderboard State
  const [leaderboard, setLeaderboard] = useState<any[]>([])

  // References Modal State
  const [showReferences, setShowReferences] = useState(false)
  
  // Examples Modal State
  const [showExamples, setShowExamples] = useState(false)
  
  // Milestones Modal State
  const [showMilestones, setShowMilestones] = useState(false)

  // Current Battle Region State (for achievement tracking)
  const [currentBattleRegion, setCurrentBattleRegion] = useState<string | null>(null)

  // Usage Session Tracking
  const usageSession = useUsageSession(
    currentAppUser?.username || null,
    {
      appView: appView,
      gameStatus: gameStatus,
      trainer: currentTrainer?.name
    }
  )

  // Supabase Database Functions
  
  // Load all trainers from database
  async function loadTrainers(userId?: string) {
    try {
      let query = supabase.from('trainers').select('*')
      
      // If userId is provided, filter by user_id
      if (userId) {
        query = query.eq('user_id', userId)
      }
      
      const { data, error } = await query
      
      if (error) {
        console.error('Error loading trainers:', error)
        return []
      }
      
      return data || []
    } catch (error) {
      console.error('Error loading trainers:', error)
      return []
    }
  }
  
  // Load Pokemon inventory for a trainer from database
  async function loadPokemonInventory(trainerId: string) {
    try {
      const { data, error } = await dbHelpers.getTrainerInventory(trainerId)
      
      if (error) {
        console.error('Error loading Pokemon inventory:', error)
        return []
      }
      
      const trainerPokemon = data || []
      setPokemonInventory(trainerPokemon)
      
      // Get total_points from leaderboard view (includes pokemon points + achievement points)
      const { data: trainerData } = await supabase
        .from('trainer_leaderboard')
        .select('total_points')
        .eq('id', trainerId)
        .single()
      
      const points = trainerData?.total_points || 0
      setTotalPoints(points)
      
      return trainerPokemon
    } catch (error) {
      console.error('Error loading Pokemon inventory:', error)
      return []
    }
  }
  
  // Get the first trainer from database
  async function getFirstTrainer() {
    const trainers = await loadTrainers()
    if (trainers.length > 0) {
      const trainer = trainers[0]
      setCurrentTrainer(trainer)
      
      // Load their Pokemon from database
      const pokemonData = await loadPokemonInventory(trainer.id)
      
      // Send trainer and Pokemon data to game
      await sendTrainerToGame(trainer.name)
      await sendPokemonInventoryToGame(pokemonData)
      
      return trainer
    }
    return null
  }

  // Load leaderboard from database
  async function loadLeaderboard() {
    try {
      console.log('Loading leaderboard...')
      
      // Try querying the view
      const { data, error } = await supabase
        .from('trainer_leaderboard')
        .select('*')
        .order('total_points', { ascending: false })
        .limit(6)
      
      console.log('Leaderboard data:', data)
      console.log('Leaderboard error:', error)
      
      if (error) {
        console.error('Error loading leaderboard:', error)
        console.error('Error details:', {
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code
        })
        
        // If view fails, try direct query from trainers table as fallback
        console.log('Falling back to direct trainers query...')
        const { data: trainersData, error: trainersError } = await supabase
          .from('trainers')
          .select('id, name, total_points, created_at, user_id')
          .order('total_points', { ascending: false })
          .limit(6)
        
        if (trainersError) {
          console.error('Fallback query also failed:', trainersError)
          return []
        }
        
        setLeaderboard(trainersData || [])
        console.log('Leaderboard set from fallback:', trainersData)
        return trainersData || []
      }
      
      setLeaderboard(data || [])
      console.log('Leaderboard set to:', data)
      return data || []
    } catch (error) {
      console.error('Error loading leaderboard:', error)
      return []
    }
  } 
  const pyodideInstance = usePyodide()
  useEffect(() => {
    if (pyodideInstance) {
      setPyodide(pyodideInstance)
      setOutput('Pyodide loaded')
    }

    // Listen for messages from Godot
    const handleMessage = (event: MessageEvent) => {
      if (event.data && event.data.type === 'GODOT_MESSAGE') {
        handleGodotMessage(event.data.data)
      }
    }

    window.addEventListener('message', handleMessage)
    
    // Cleanup
    return () => {
      window.removeEventListener('message', handleMessage)
    }
  }, [pyodideInstance])

  // Initialize app when it loads
  useEffect(() => {
    initializeApp()
  }, [])

  async function initializeApp() {
    // For now, just load trainers without forcing authentication
    // The login system is available but not required
    const trainers = await loadTrainers()
    setAllTrainers(trainers)
    
    // Load leaderboard
    await loadLeaderboard()
    
    if (trainers.length > 0) {
      setOutput(`Found ${trainers.length} trainer(s) in database. ${currentAppUser ? 'Logged in!' : 'Playing as guest.'}`)
    } else {
      setOutput('⚠️ No trainers found in database.')
    }
  }

  // ===== Login/Signup Functions =====
  
  async function handleLoginSubmit(e: React.FormEvent) {
    e.preventDefault()
    setAuthBusy(true)
    setAuthMessage(null)

    try {
      // Query test_username table for username/password match
      const { data, error } = await supabase
        .from('test_username')
        .select('*')
        .eq('username', loginUsername)
        .eq('password', loginPassword)
        .single()

      if (error || !data) {
        setAuthMessage('❌ Invalid username or password')
        setAuthBusy(false)
        return
      }

      // Login successful
      setCurrentAppUser(data)
      currentAppUserRef.current = data // Keep ref in sync
      setShowLogin(false)
      setAuthMessage(null)
      setLoginUsername('')
      setLoginPassword('')

      // Load user's trainers and auto-select the first one
      const userTrainers = await loadTrainers(data.id)
      if (userTrainers.length > 0) {
        const trainer = userTrainers[0]
        setCurrentTrainer(trainer)
        currentTrainerRef.current = trainer
        
        // Initialize user stats and update login streak
        await initializeUserStats(data.id, trainer.id)
        await updateLoginStreak(data.id, trainer.id)
        
        const pokemonData = await loadPokemonInventory(trainer.id)
        await sendTrainerToGame(trainer.name)
        await sendPokemonInventoryToGame(pokemonData)
        setOutput(`✅ Welcome back, ${data.username}! Trainer "${trainer.name}" selected with ${pokemonData.length} Pokemon.`)
      } else {
        setOutput(`✅ Welcome back, ${data.username}! No trainer found for your account.`)
      }
      
      setAppView('dashboard')
    } catch (err) {
      setAuthMessage('❌ Login failed')
    } finally {
      setAuthBusy(false)
    }
  }

  // async function handleSignupSubmit(username: string, password: string) {
  //   setAuthBusy(true)
  //   setAuthMessage(null)

  //   try {
  //     // Check if username exists
  //     const { data: existing } = await supabase
  //       .from('test_username')
  //       .select('username')
  //       .eq('username', username)
  //       .single()

  //     if (existing) {
  //       setAuthMessage('❌ Username already taken')
  //       setAuthBusy(false)
  //       return false
  //     }

  //     // Create new user
  //     const { data: newUser, error } = await supabase
  //       .from('test_username')
  //       .insert([{ username, password }])
  //       .select()
  //       .single()

  //     if (error || !newUser) {
  //       setAuthMessage('❌ Signup failed')
  //       setAuthBusy(false)
  //       return false
  //     }

  //     // Auto-login after signup
  //     setCurrentAppUser(newUser)
  //     setAppView('dashboard')
  //     setOutput(`🎉 Account created! Welcome, ${newUser.username}!`)
  //     return true
  //   } catch (err) {
  //     setAuthMessage('❌ Signup error')
  //     return false
  //   } finally {
  //     setAuthBusy(false)
  //   }
  // }

  async function handleGodotMessage(data: any) {
    if (data.type === 'BATTLE_STARTED') {
      console.log('Received BATTLE_STARTED event from Godot:', data)
      console.log('🌍 Battle data region:', data.data?.region, 'Full data:', data.data)
      setGameStatus('battle')
      setCurrentBattlePokemon(data.data)
      setIsTaskActive(true)
      taskCompletionSentRef.current = false // Reset flag for new battle
      // Store the current battle region for achievement tracking
      const battleRegion = data.data?.region || 'Forest'
      console.log('🌍 Setting battle region to:', battleRegion)
      setCurrentBattleRegion(battleRegion)
      // Pass the region from the battle data to get region-specific tasks
      loadRandomTask(data.data?.region || null)
    } else if (data.type === 'BATTLE_ENDED') {
      setGameStatus('menu')
      setIsTaskActive(false)
      setCurrentTask(null)
      setCurrentBattlePokemon(null)
      setCurrentBattleRegion(null) // Clear battle region
      taskCompletionSentRef.current = false // Reset flag
      setCode(`# PyMon Creature Collector
# 
# HOW TO PLAY:
# 1. Move around the map using ARROW KEYS or WASD
# 2. Walk through unique grass to encounter Pokemon
# 3. When a battle starts, solve the Python programming task
# 4. Click "Evaluate Code" to check your solution
# 5. If correct, you capture the Pokemon!
# 6. Collect all Pokemon and become the ultimate trainer!
#
# Press ENTER in the game to start the game!

print("Ready to start your adventure!")`)
      setOutput('Battle ended! Ready for next encounter.')
    } else if (data.type === 'POKEMON_FLED') {
      // Pokemon fled due to time limit
      setGameStatus('menu')
      setIsTaskActive(false)
      setCurrentTask(null)
      setCurrentBattlePokemon(null)
      setCurrentBattleRegion(null) // Clear battle region
      taskCompletionSentRef.current = false
      setCode(`# PyMon Creature Collector
# 
# HOW TO PLAY:
# 1. Move around the map using ARROW KEYS or WASD
# 2. Walk through unique grass to encounter Pokemon
# 3. When a battle starts, solve the Python programming task
# 4. Click "Evaluate Code" to check your solution
# 5. If correct, you capture the Pokemon!
# 6. Collect all Pokemon and become the ultimate trainer!
#
# Press ENTER in the game to start the game!

print("Ready to start your adventure!")`)
      setOutput(`💨 ${data.data?.pokemon_name || 'Pokemon'} fled! You ran out of time. Try to be faster next time!`)
    } else if (data.type === 'POKEMON_CAPTURED') {
      handlePokemonCapture(data)
    } else if (data.type === 'ENTER_PRESSED_IN_GAME') {
      console.log('Current trainer:', currentTrainer)
      console.log('Current trainer ref:', currentTrainerRef.current)
      setOutput('⏳ Game starting...')
      
      setTimeout(async () => {
        // Use ref as it's more reliable than state
        const trainer = currentTrainerRef.current || currentTrainer
        
        if (trainer) {
          console.log('Sending trainer to game:', trainer.name)
          
          // Load the trainer's Pokemon inventory from database
          const pokemonData = await loadPokemonInventory(trainer.id)
          
          // Send trainer and inventory to game
          await sendTrainerToGame(trainer.name)
          await sendPokemonInventoryToGame(pokemonData)
          
          setOutput(`Game started! Trainer ${trainer.name} loaded with ${pokemonData.length} Pokemon.`)
        } else {
          console.error('No trainer found! currentTrainer:', currentTrainer, 'currentTrainerRef:', currentTrainerRef.current)
          setOutput('No trainer selected. Please select a trainer first.')
        }
      }, 500)
    } else if (data.type === 'request_current_trainer') {
      // Send current trainer to Godot, or load CSV data if no trainer exists
      if (currentTrainer) {
        await sendTrainerToGame(currentTrainer.name)
        if (pokemonInventory.length > 0) {
          await sendPokemonInventoryToGame(pokemonInventory)
        }
      } else {
        getFirstTrainer().then((trainer: any) => {
          if (trainer) {
            setOutput(`Auto-loaded trainer: ${trainer.name} for game`)
          }
        })
      }
    } else if (data.type === 'request_csv_data') {
      // Load data from database and send to Godot
      getFirstTrainer().then((trainer: any) => {
        if (trainer) {
          setOutput(`Trainer data loaded: ${trainer.name} with ${pokemonInventory.length} Pokemon`)
        }
      })
    }
  }

  // Handle Pokemon capture from Godot
  async function handlePokemonCapture(captureData: any) {
    console.log('📦 Full capture data:', captureData)
    
    // Use ref as fallback since state might not be updated yet
    const trainer = currentTrainerRef.current || currentTrainer
    
    if (!trainer) {
      setOutput('⚠️ Warning: No trainer selected. Please select a trainer before capturing Pokemon.')
      return
    }

    const pokemonData = {
      name: captureData.data?.pokemon_name || captureData.pokemon_name || 'Unknown',
      level: captureData.data?.level || captureData.level || 1,
      points: captureData.data?.points || captureData.points || 100,
      captured_at: captureData.data?.captured_at || captureData.captured_at || new Date().toISOString(),
      capture_time_ms: captureData.data?.capture_time_ms || captureData.capture_time_ms || null
    }
    
    // Extract region from capture data
    const captureRegion = captureData.data?.region || captureData.region || currentBattleRegion || 'Forest'
    console.log('🗺️ Capture region:', captureRegion, 'from data:', captureData.data?.region || captureData.region, 'or state:', currentBattleRegion)

    // Extract time bonus info if available
    const basePoints = captureData.data?.base_points || null
    const timeBonus = captureData.data?.time_bonus || null
    const timePercentage = captureData.data?.time_percentage || null
    const captureTimeSeconds = pokemonData.capture_time_ms ? (pokemonData.capture_time_ms / 1000).toFixed(2) : null

    // Add to database using trainer from ref/state
    const success = await addPokemonToDatabase(trainer.id, pokemonData)
    
    if (success) {
      // Create detailed output message with time bonus info
      let outputMessage = `${pokemonData.name} (Lv.${pokemonData.level}) captured and saved to database!\n\n`
      
      if (captureTimeSeconds) {
        outputMessage += `⏱️ Solve Time: ${captureTimeSeconds}s\n`
      }
      
      if (basePoints !== null && timeBonus !== null && timePercentage !== null) {
        outputMessage += `💰 Base Points: ${basePoints}\n`
        outputMessage += `⏱️ Time Bonus: +${timeBonus} (${timePercentage}% remaining)\n`
        outputMessage += `✨ Total: ${pokemonData.points} points`
      } else {
        outputMessage += `+${pokemonData.points} points`
      }
      
      setOutput(outputMessage)
      
      // Update achievement stats for this capture
      // Use ref since state might not be updated yet
      const appUser = currentAppUserRef.current || currentAppUser
      
      console.log('🔍 Achievement tracking check:', { 
        appUser: appUser,
        appUserFromState: currentAppUser,
        appUserFromRef: currentAppUserRef.current,
        hasAppUser: !!appUser?.id, 
        hasTrainer: !!trainer?.id,
        hasRegion: !!captureRegion,
        appUserId: appUser?.id,
        trainerId: trainer?.id,
        region: captureRegion
      })
      
      if (appUser?.id && captureRegion) {
        console.log('🎯 Tracking achievement for capture in region:', captureRegion)
        await updateCaptureStats(appUser.id, trainer.id, captureRegion)
        console.log('✅ Achievement stats updated successfully!')
      } else {
        console.warn('⚠️ Cannot track achievement - missing data:', { 
          hasUserId: !!appUser?.id, 
          hasTrainerId: !!trainer?.id, 
          region: captureRegion,
          note: !appUser?.id ? 'User not logged in - appUser is null' : 'Missing region data'
        })
      }
      
      // Refresh the inventory display
      await loadPokemonInventory(trainer.id)
      
      // Send updated inventory to game
      const updatedInventory = await loadPokemonInventory(trainer.id)
      await sendPokemonInventoryToGame(updatedInventory)
      
      // Refresh leaderboard after capture
      await loadLeaderboard()
    } else {
      setOutput(`${pokemonData.name} captured in game, but failed to save to database. Check console for details. (Hint: You may need to disable RLS in Supabase)`)
    }
  }

  // Add Pokemon to Supabase database
  async function addPokemonToDatabase(trainerId: string, pokemonData: {
    name: string,
    level: number,
    points: number,
    captured_at: string,
    capture_time_ms?: number | null
  }) {
    try {
      console.log('Attempting to add Pokemon to database:', { trainerId, pokemonData })
      
      // Insert into pokemon_inventory table
      const { data: insertedData, error } = await supabase
        .from('pokemon_inventory')
        .insert([
          {
            trainer_id: trainerId,
            pokemon_name: pokemonData.name,
            level: pokemonData.level,
            points: pokemonData.points,
            captured_at: pokemonData.captured_at,
            capture_time_ms: pokemonData.capture_time_ms
          }
        ])
        .select()
      
      if (error) {
        console.error('Error adding Pokemon to database:', error)
        console.error('Error details:', {
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code
        })
        return false
      }
      
      console.log('Pokemon inserted successfully:', insertedData)
      
      // Note: Trainer's total_points is automatically updated by database triggers
      // No manual update needed here - the trigger recalculates from pokemon_inventory
      
      return true
    } catch (error) {
      console.error('Error adding Pokemon to database:', error)
      return false
    }
  }

  // Load a random programming task from database
  async function loadRandomTask(region: string | null = null) {
    try {
      console.log('Loading random task for region:', region)
      const { data, error } = await supabase
        .rpc('get_random_task', { task_category: region })
      
      console.log('Task data:', data)
      console.log('Task error:', error)
      
      if (error) {
        console.error('Error loading task:', error)
        console.error('Error details:', JSON.stringify(error, null, 2))
        setOutput(`❌ Failed to load programming task: ${error.message || 'Unknown error'}`)
        setIsTaskActive(false)
        return
      }
      
      if (data && data.length > 0) {
        const task = data[0]
        console.log('Task loaded:', task)
        setCurrentTask(task)
        setCode(task.starter_code || '')
        setOutput(`Region: ${region || 'Any'} \n\nTask: ${task.title}\n\n${task.description}\n\nSolve this task to capture the Pokemon!`)
      } else {
        console.warn('No tasks found in database for region:', region)
        setOutput('❌ No tasks available for this region. Please run the database migration.')
        setIsTaskActive(false)
      }
    } catch (error: any) {
      console.error('Error loading task:', error)
      console.error('Error stack:', error.stack)
      setOutput(`❌ Failed to load programming task: ${error.message || 'Unknown error'}`)
      setIsTaskActive(false)
    }
  }

  // Validate if the code output matches the expected output
  function validateTaskOutput(userOutput: string, expectedOutput: string): boolean {
    // Normalize outputs for comparison
    const normalizeOutput = (output: string) => {
      return output
        .trim()
        .replace(/\s+/g, ' ')
        .replace(/'/g, '"') // Normalize quotes
        .toLowerCase()
    }
    
    const normalizedUserOutput = normalizeOutput(userOutput)
    const normalizedExpectedOutput = normalizeOutput(expectedOutput)
    
    return normalizedUserOutput === normalizedExpectedOutput
  }

  // Send task completion result to game
  function sendTaskCompletionToGame(completed: boolean) {
    console.log('Sending task completion to game:', completed)
    const gameFrame = document.querySelector('.game-frame') as HTMLIFrameElement
    if (gameFrame && gameFrame.contentWindow) {
      const message = {
        type: 'TASK_COMPLETED',
        completed: completed,
        task_id: currentTask?.id
      }
      console.log('Posting message to game:', message)
      gameFrame.contentWindow.postMessage(message, '*')
    } else {
      console.error('Game frame not found or no contentWindow')
    }
  }

  async function runPythonCode() {
    if (!pyodide) return

    try {
      await pyodide.runPythonAsync(`
          import sys
          from io import StringIO
          sys.stdout = sys.stderr = mystdout = StringIO()
              `)

      await pyodide.runPythonAsync(code)

      const outputText = await pyodide.runPythonAsync("mystdout.getvalue()")
      
      // If in battle with active task, validate the output
      if (isTaskActive && currentTask) {
        const isCorrect = validateTaskOutput(outputText, currentTask.expected_output)
        
        if (isCorrect) {
          setOutput(`✅ Correct! Output: ${outputText}\n\n🎉 Task completed successfully!`)
          setTaskOutput(outputText)
          // Send success to game to trigger capture (only once)
          if (!taskCompletionSentRef.current) {
            taskCompletionSentRef.current = true
            sendTaskCompletionToGame(true)
          }
        } else {
          setOutput(`❌ Incorrect!\n\nYour output: ${outputText}\n\nExpected: ${currentTask.expected_output}\n\nTry again!`)
          taskCompletionSentRef.current = false // Reset for retry
          sendTaskCompletionToGame(false)
        }
      } else {
        // Normal mode (no active task)
        setOutput(outputText || 'No output')
        
      }
    } catch (err: any) {
      setOutput('Error: ' + err.message)
      if (isTaskActive) {
        sendTaskCompletionToGame(false)
      }
    }
  }

  async function sendTrainerToGame(trainerName: string) {
    const gameFrame = document.querySelector('.game-frame') as HTMLIFrameElement
    if (gameFrame && gameFrame.contentWindow) {
      // Get the trainer's total_points from leaderboard view (includes pokemon + achievement points)
      const trainer = currentTrainerRef.current || currentTrainer
      let totalPoints = 0
      
      if (trainer?.id) {
        const { data, error } = await supabase
          .from('trainer_leaderboard')
          .select('total_points')
          .eq('id', trainer.id)
          .single()
        
        console.log('📊 sendTrainerToGame - Query result:', data, 'Error:', error)
        totalPoints = data?.total_points || 0
        console.log('📊 sendTrainerToGame - Sending total_points:', totalPoints)
      }
      
      gameFrame.contentWindow.postMessage({
        type: 'TRAINER_SELECTED',
        trainer_name: trainerName,
        total_points: totalPoints
      }, '*')
    }
  }

  async function sendPokemonInventoryToGame(pokemonData: any[]) {
    const gameFrame = document.querySelector('.game-frame') as HTMLIFrameElement
    if (gameFrame && gameFrame.contentWindow) {
      // Get the trainer's total_points from leaderboard view (includes pokemon + achievement points)
      const trainer = currentTrainerRef.current || currentTrainer
      let totalPoints = 0
      
      if (trainer?.id) {
        const { data, error } = await supabase
          .from('trainer_leaderboard')
          .select('total_points')
          .eq('id', trainer.id)
          .single()
        
        console.log('📊 sendPokemonInventoryToGame - Query result:', data, 'Error:', error)
        totalPoints = data?.total_points || 0
        console.log('📊 sendPokemonInventoryToGame - Sending total_points:', totalPoints, 'Pokemon count:', pokemonData.length)
      }
      
      gameFrame.contentWindow.postMessage({
        type: 'POKEMON_INVENTORY_UPDATE',
        pokemon_data: pokemonData,
        total_points: totalPoints
      }, '*')
    }
  }

  // ===== View Routing =====
  
  // Welcome view (login screen)
  if (appView === 'welcome') {
    return (
      <div>
        <WelcomeView onOpenLogin={() => setShowLogin(true)}>
          <LoginModal
            open={showLogin}
            onClose={() => setShowLogin(false)}
            authMessage={authMessage}
            authBusy={authBusy}
            loginUsername={loginUsername}
            setLoginUsername={setLoginUsername}
            loginPassword={loginPassword}
            setLoginPassword={setLoginPassword}
            onSubmit={handleLoginSubmit}
            onSignupClick={() => {
              setShowLogin(false)
              setAppView('signup')
            }}
          />
        </WelcomeView>
        
        {/* Play as Guest button */}
        <div className="guest-login-container">
          <button
            onClick={() => {
              setCurrentAppUser(null)
              currentAppUserRef.current = null
              setAppView('main')
              setOutput('Playing as guest')
            }}
            className="guest-login-button"
          >
            Skip Login - Play as Guest
          </button>
        </div>
      </div>
    )
  }

  // Signup view
  if (appView === 'signup') {
    return (
      <SignupView
        onBack={() => setAppView('welcome')}
        onSuccess={async (username: string) => {
          // Auto-login after signup
          const { data } = await supabase
            .from('test_username')
            .select('*')
            .eq('username', username)
            .single()
          
          if (data) {
            setCurrentAppUser(data)
            currentAppUserRef.current = data

            // Record first login for streak & unlock streak achievements
            try {
              await supabase.from('login_events').insert({ username })
              const { data: streak, error: streakErr } = await supabase.rpc('compute_login_streak', {
                p_username: username
              })
              if (!streakErr && streak != null) {
                const { data: unlocked, error: unlockErr } = await supabase.rpc('check_achievements', {
                  p_username: username,
                  p_metric: 'login_streak_days',
                  p_value: streak
                })
                if (unlockErr) {
                  console.error('Signup login streak achievement check error:', unlockErr)
                } else if (unlocked && unlocked.length > 0) {
                  console.log('🎉 Signup streak achievements unlocked:', unlocked)
                }
              } else if (streakErr) {
                console.error('compute_login_streak error:', streakErr)
              }
            } catch (e) {
              console.error('Signup streak tracking failed:', e)
            }

            // Load user's trainer (should be the one just created)
            const userTrainers = await loadTrainers(data.id)
            if (userTrainers.length > 0) {
              const trainer = userTrainers[0]
              setCurrentTrainer(trainer)
              currentTrainerRef.current = trainer
              const pokemonData = await loadPokemonInventory(trainer.id)
              await sendTrainerToGame(trainer.name)
              await sendPokemonInventoryToGame(pokemonData)
              setOutput(`🎉 Account created! Welcome, ${username}! Trainer "${trainer.name}" ready!`)
            } else {
              setOutput(`🎉 Account created! Welcome, ${username}!`)
            }

            setAppView('dashboard')
          }
        }}
      />
    )
  }

  // Dashboard view (after login, before entering game)
  if (appView === 'dashboard') {
    return (
      <DashboardView
        username={currentAppUser?.username}
        onEnterGame={() => {
          setAppView('main')
          // Don't send trainer yet - wait for GAME_STARTED signal from Godot
          setOutput('Game loading... Press ENTER to start.')
        }}
        onLogout={async () => {
          // End usage session before logout
          if (usageSession.sessionActive) {
            await usageSession.endSession()
          }
          setCurrentAppUser(null)
          currentAppUserRef.current = null
          setCurrentTrainer(null)
          setAppView('welcome')
          setOutput('👋 Logged out')
        }}
      />
    )
  }

  // Main game view (the existing game UI)
  return (
    <div className="app-container with-user-bar">
      {/* User Info Bar */}
      <div className="user-info-bar">
        <span className="trainer-username">
          {currentAppUser ? `Trainer: ${currentAppUser.username}` : 'Playing as Guest'}
        </span>
        <div className="user-bar-buttons">
          <button
            onClick={() => setShowReferences(true)}
            className="references-button"
          >
            References
          </button>
          <button
            onClick={() => setShowExamples(true)}
            className="examples-button"
          >
            Examples
          </button>
          {currentAppUser && (
            <button
              onClick={() => setShowMilestones(true)}
              className="milestones-button"
            >
              Milestones
            </button>
          )}
          <button
            onClick={async () => {
              if (currentAppUser) {
                // End usage session before logout
                if (usageSession.sessionActive) {
                  await usageSession.endSession()
                }
                setCurrentAppUser(null)
                currentAppUserRef.current = null
                setCurrentTrainer(null)
                setAppView('welcome')
              } else {
                // Guest mode - go to login
                setAppView('welcome')
              }
            }}
            className={currentAppUser ? "logout-button" : "login-button"}
          >
            {currentAppUser ? 'Logout' : 'Login'}
          </button>
        </div>
      </div>

      {/* Left Side - Game Only */}
      <div className="left-panel">
        {/* Game Section */}
        <div className="game-section">
          <h3>PyMon - Creature Collector</h3>
          <iframe 
            src="/PokePoP/game/web/Pokemon_Clone.html"
            width="100%"
            height="100%"
            title="Pokemon Clone Game"
            className="game-frame"
            onLoad={() => {
              console.log('Game iframe loaded, waiting for GAME_STARTED signal...')
              setOutput('Press ENTER in game to start')
            }}
            // allow="fullscreen"
          />
        </div>

        {/* Leaderboard Section */}
        <div className="leaderboard-section">
          <h3>🏆 Top Trainers</h3>
          {leaderboard.length > 0 ? (
            <div className="leaderboard-grid">
              {leaderboard.map((trainer, index) => (
                <div key={trainer.id} className="leaderboard-item">
                  <span className="leaderboard-rank">#{index + 1}</span>
                  <div className="leaderboard-info">
                    <span className="leaderboard-name">{trainer.name}</span>
                    <span className="leaderboard-points">⭐ {trainer.total_points}</span>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div style={{ color: '#9ca3af', textAlign: 'center', padding: '1rem' }}>
              No trainers found. Start capturing Pokemon!
            </div>
          )}
        </div>
      </div>

      {/* Right Side - Python Editor Only */}
      <div className="right-panel">
        {/* Python Editor Section - Compact */}
        <div className="python-section-compact">
          <h3>Python Editor</h3>
          
          {/* Game Status Indicator */}
          <div className={`game-status-indicator ${gameStatus === 'battle' ? 'game-status-battle' : 'game-status-overworld'}`}>
            {gameStatus === 'battle' ? 'IN BATTLE' : 'OVERWORLD'}
          </div>
          
          <div className="code-editor-wrapper">
            <SyntaxHighlighter
              language="python"
              style={vscDarkPlus}
              customStyle={{
                margin: 0,
                borderRadius: '4px',
                fontSize: '16px',
                lineHeight: '1.4',
                height: '100%',
                minHeight: '300px',
              }}
              showLineNumbers={true}
              wrapLines={true}
              lineNumberStyle={{ minWidth: '3em', paddingRight: '1em', color: '#858585' }}
            >
              {code}
            </SyntaxHighlighter>
            <textarea
              value={code}
              onChange={(e) => setCode(e.target.value)}
              onKeyDown={(e) => {
                  // Ensure that tab is working in the editor 
                if (e.key === 'Tab') {
                  e.preventDefault()
                  const target = e.target as HTMLTextAreaElement
                  const start = target.selectionStart
                  const end = target.selectionEnd
                  const newValue = code.substring(0, start) + '    ' + code.substring(end)
                  setCode(newValue)
                  // Set cursor after inserted tab
                  setTimeout(() => {
                    target.selectionStart = target.selectionEnd = start + 4
                  }, 0)
                }
              }}
              placeholder="Write your Python code here..."
              className="python-textarea-overlay"
              spellCheck={false}
            />
          </div>


          <button onClick={runPythonCode} className="run-button-compact">
            ▶️ Evaluate Code
          </button>

          <pre className="python-output-compact">
            {output}
          </pre>
        </div>
      </div>

      {/* References Modal */}
      <ReferencesModal show={showReferences} onClose={() => setShowReferences(false)} />

      {/* Examples Modal */}
      <ExamplesModal show={showExamples} onClose={() => setShowExamples(false)} />
      
      {/* Milestones Modal */}
      <MilestonesModal 
        show={showMilestones} 
        onClose={() => setShowMilestones(false)}
        userId={currentAppUser?.id || null}
      />
    </div>
  )
}

export default App 
