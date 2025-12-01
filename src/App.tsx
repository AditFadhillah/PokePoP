import { useState, useEffect, useRef } from 'react'
import './App.css'
import { usePyodide } from './lib/usepyodide'
import { supabase, dbHelpers } from './lib/supabase'
// import { supabase as supabaseAuth } from './lib/databaseFunctions'
import { useUsageSession } from './lib/useUsageSession'
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter'
import { vscDarkPlus } from 'react-syntax-highlighter/dist/esm/styles/prism'
import { updateCaptureStats, initializeUserStats, updateLoginStreak } from './lib/achievementHelpers'

// Import neurogen login views and components
import WelcomeView from './views/welcomeView'
import SignupView from './views/signupView'
// import DashboardView from './views/dashboardView'
import LoginModal from './components/loginmodal'
import ExamplesModal from './views/ExamplesModal'
import ReferencesModal from './views/ReferencesModal'
import MilestonesModal from './views/MilestonesModal'
import IndividualLeaderboardModal from './views/IndividualLeaderboardModal'
import VolunteerModal from './views/VolunteerModal'
import TeamLeaderboardPanel from './views/TeamLeaderboardPanel'

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
  const lastTaskOutputRef = useRef<string>('')
  
  // Track last 2 task IDs to prevent repetition
  const [recentTaskIds, setRecentTaskIds] = useState<string[]>([])

  // References Modal State
  const [showReferences, setShowReferences] = useState(false)
  
  // Examples Modal State
  const [showExamples, setShowExamples] = useState(false)
  
  // Milestones Modal State
  const [showMilestones, setShowMilestones] = useState(false)

  // Tutorial Modal State
  const [showTutorial, setShowTutorial] = useState(false)

  // Individual Leaderboard Modal State
  const [showIndividualLeaderboard, setShowIndividualLeaderboard] = useState(false)

  // Volunteer Modal State
  const [showVolunteer, setShowVolunteer] = useState(false)

  // Mute State
  const [isMuted, setIsMuted] = useState(false)

  // Current Battle Region State (for achievement tracking)
  const [currentBattleRegion, setCurrentBattleRegion] = useState<string | null>(null)

  // Hint System State
  const [currentHintIndex, setCurrentHintIndex] = useState(0)
  const [currentHint, setCurrentHint] = useState('')
  const hintIntervalRef = useRef<NodeJS.Timeout | null>(null)
  
  // Code editor refs for scroll synchronization
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const syntaxHighlighterRef = useRef<HTMLDivElement>(null)
  
  // Refresh timestamp to trigger leaderboard updates
  const [leaderboardRefreshKey, setLeaderboardRefreshKey] = useState(0)
  
  // Array of helpful hints for exploration
  const explorationHints = [
    "💡 Tip: Explore all 4 regions!",
    "💡 Each region has different types of programming tasks.",
    "💡 Press F to interact with objects in the world!",
    "💡 Look for Tall Grass - Pokemon hide there!",
    "💡 Orange Crystal Boulders contain Pokemon - investigate them!",
    "💡 Washed up Kelp on the beach has Pokemon - check it out!",
    "💡 Each region has unique Pokemon and tasks - explore them all!",
    "💡 Forest Region: Master loops and iterations - for loops and nested loops",
    "💡 Beach Region: Learn dictionaries - key-value pairs, merging, and lookups!",
    "💡 Volcano Region: Practice regex patterns - search, replace, and validate!",
    "💡 Swamp Region: Explore data structures - tuples and comprehensions!"

  ]
  
  // Array of helpful hints for battle
  const battleHints = [
    "💡 Stuck on a task? Click the References button for Python syntax help!",
    "💡 Need inspiration? Check the Examples button for code samples!",
    "💡 Select RUN and press ENTER if you don't want to capture this Pokemon!",
    "💡 Track your progress! Click Achievements to see your milestones!"
  ]

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
        .limit(8)
      
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
          .limit(8)
        
        if (trainersError) {
          console.error('Fallback query also failed:', trainersError)
          return []
        }
        
        console.log('Leaderboard set from fallback:', trainersData)
        return trainersData || []
      }
      
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

  // Hint cycling system - shows helpful tips during exploration and battle
  useEffect(() => {
    // Clear any existing interval
    if (hintIntervalRef.current) {
      clearInterval(hintIntervalRef.current)
    }

    // Choose appropriate hint array based on game status
    const hints = gameStatus === 'battle' ? battleHints : explorationHints
    
    // Show first hint immediately
    setCurrentHint(hints[currentHintIndex % hints.length])

    // Set up interval to cycle through hints every 10 seconds
    hintIntervalRef.current = setInterval(() => {
      setCurrentHintIndex((prevIndex) => {
        const nextIndex = (prevIndex + 1) % hints.length
        setCurrentHint(hints[nextIndex])
        return nextIndex
      })
    }, 10000) // 10 seconds between hints

    // Cleanup function
    return () => {
      if (hintIntervalRef.current) {
        clearInterval(hintIntervalRef.current)
        hintIntervalRef.current = null
      }
    }
  }, [gameStatus, currentHintIndex, explorationHints, battleHints])

  // Scroll sync - transform syntax highlighter to follow textarea scroll
  useEffect(() => {
    const textarea = textareaRef.current
    const wrapper = syntaxHighlighterRef.current
    
    if (!textarea || !wrapper) return
    
    const handleTextareaScroll = () => {
      const scrollTop = textarea.scrollTop
      const scrollLeft = textarea.scrollLeft
      
      // Find the syntax highlighter div (first child of wrapper)
      const highlighterDiv = wrapper.firstElementChild as HTMLElement
      if (highlighterDiv) {
        highlighterDiv.style.transform = `translate(${-scrollLeft}px, ${-scrollTop}px)`
      }
    }
    
    textarea.addEventListener('scroll', handleTextareaScroll)
    
    // Initial sync
    handleTextareaScroll()
    
    return () => {
      textarea.removeEventListener('scroll', handleTextareaScroll)
    }
  }, [code])

  async function initializeApp() {
    // For now, just load trainers without forcing authentication
    // The login system is available but not required
    const trainers = await loadTrainers()
    setAllTrainers(trainers)
    
    // Load leaderboard
    await loadLeaderboard()
    
    // if (trainers.length > 0) {
    //   setOutput(`Found ${trainers.length} trainer(s) in database. ${currentAppUser ? 'Logged in!' : 'Playing as guest.'}`)
    // } else {
    //   setOutput('⚠️ No trainers found in database.')
    // }
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
          setOutput('Playing as guest. Progress will not be saved. Please log in to track your achievements!')
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
    
    // if (!trainer) {
    //   setOutput('⚠️ Warning: No trainer selected. Please select a trainer before capturing Pokemon.')
    //   return
    // }  

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
    const captureTimeSeconds = pokemonData.capture_time_ms ? (pokemonData.capture_time_ms / 1000).toFixed(2) : null

    // Add to database using trainer from ref/state
    const success = await addPokemonToDatabase(trainer.id, pokemonData)
    
    if (success) {
      // Get the actual task output from the ref (stored during validation)
      const taskOutput = lastTaskOutputRef.current || captureData.data?.task_output || captureData.task_output || currentTask?.expected_output || ''
      
      // Create detailed output message combining task success and capture info
      let outputMessage = `✅ Correct! Output: ${taskOutput}\n\n🎉 ${pokemonData.name.toUpperCase()} (Lv.${pokemonData.level}) captured!\n\n`
      
      if (captureTimeSeconds) {
        outputMessage += `⏱️ Solve Time: ${captureTimeSeconds}s\n`
      }
      
      if (basePoints !== null && timeBonus !== null) {
        outputMessage += `💰 Points: ${basePoints} (Base) + ${timeBonus} (Time Bonus)\n`
        outputMessage += `✨ Total: ${pokemonData.points} points`
      } else {
        outputMessage += `✨ Total: ${pokemonData.points} points`
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
      
      // Refresh current trainer's total_points from leaderboard view
      const { data: updatedTrainerData, error: leaderboardError } = await supabase
        .from('trainer_leaderboard')
        .select('*')
        .eq('id', trainer.id)
        .single()
      
      if (updatedTrainerData && !leaderboardError) {
        // Create a new trainer object with updated points to trigger React re-render
        const updatedTrainer = { 
          ...currentTrainer,
          ...trainer,
          total_points: updatedTrainerData.total_points 
        }
        setCurrentTrainer(updatedTrainer)
        currentTrainerRef.current = updatedTrainer
        setTotalPoints(updatedTrainerData.total_points)
        console.log('✅ Updated current trainer points to:', updatedTrainerData.total_points)
      } else {
        console.error('❌ Failed to fetch updated trainer points:', leaderboardError)
      }
      
      // Refresh leaderboard after capture
      await loadLeaderboard()
      
      // Trigger team leaderboard refresh
      setLeaderboardRefreshKey(prev => prev + 1)
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
      console.log('Excluding recent task IDs:', recentTaskIds)
      
      const { data, error } = await supabase
        .rpc('get_random_task', { 
          task_category: region,
          excluded_task_ids: recentTaskIds 
        })
      
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
        
        // Add task instructions as comments at the top of the starter code
        // Wrap long descriptions to multiple lines (max 70 chars per line)
        const wrapText = (text: string, maxLength: number = 70) => {
          const words = text.split(' ')
          const lines: string[] = []
          let currentLine = ''
          
          for (const word of words) {
            if ((currentLine + word).length > maxLength && currentLine.length > 0) {
              lines.push(currentLine.trim())
              currentLine = word + ' '
            } else {
              currentLine += word + ' '
            }
          }
          if (currentLine.trim().length > 0) {
            lines.push(currentLine.trim())
          }
          
          return lines.map(line => `# ${line}`).join('\n')
        }
        
        const codeWithInstructions = `# ================================================================
# Region: ${region || 'Any'}
# TASK: ${task.title}
# ================================================================
${wrapText(task.description)}
# ================================================================

${task.starter_code || ''}`
        
        setCode(codeWithInstructions)
        setOutput(`${region || 'Any'} Region - Wild Pokemon appeared!\n\nSolve the task in the editor to capture it!`)
        
        // Add this task ID to recent tasks (keep only last 2)
        setRecentTaskIds(prev => {
          const updated = [task.id, ...prev]
          return updated.slice(0, 2) // Keep only the 2 most recent
        })
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

  // Helper function to extract relevant error message from Python traceback
  function formatPythonError(errorMessage: string): string {
    // Split the error message by lines
    const lines = errorMessage.split('\n')
    
    // Look for the actual error line (usually the last non-empty line)
    const errorLines = lines.filter(line => line.trim() !== '')
    
    // Find the line with the actual error type (SyntaxError, NameError, etc.)
    const errorTypeLine = errorLines.find(line => 
      line.includes('Error:') || 
      line.match(/^\w+Error:/) ||
      line.match(/^\w+Exception:/)
    )
    
    // Find the line number and code snippet
    let lineInfo = ''
    let codeSnippet = ''
    let caretLine = ''
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      
      // Look for File "<exec>", line X pattern
      if (line.includes('File "<exec>"') || line.includes('line ')) {
        const lineMatch = line.match(/line (\d+)/)
        if (lineMatch) {
          lineInfo = `Line ${lineMatch[1]}`
          // Get the code snippet (usually next line) and caret (line after that)
          if (i + 1 < lines.length) {
            codeSnippet = lines[i + 1].trim()
          }
          if (i + 2 < lines.length && lines[i + 2].includes('^')) {
            caretLine = '    ' + lines[i + 2].trim()
          }
        }
      }
    }
    
    // Build simplified error message
    if (errorTypeLine) {
      let result = errorTypeLine.trim()
      
      if (lineInfo) {
        result = `${lineInfo}: ${result}`
      }
      
      if (codeSnippet) {
        result += `\n    ${codeSnippet}`
      }
      
      if (caretLine) {
        result += `\n${caretLine}`
      }
      
      return result
    }
    
    // Fallback: return the original error if we couldn't parse it
    return errorMessage
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
          // Store the task output in ref so handlePokemonCapture can access it
          lastTaskOutputRef.current = outputText
          setTaskOutput(outputText)
          // Send success to game to trigger capture (only once) with the task output
          if (!taskCompletionSentRef.current) {
            taskCompletionSentRef.current = true
            // Send the actual task output to the game so it can include it in capture data
            const gameFrame = document.querySelector('.game-frame') as HTMLIFrameElement
            if (gameFrame && gameFrame.contentWindow) {
              gameFrame.contentWindow.postMessage({
                type: 'TASK_COMPLETED',
                completed: true,
                task_id: currentTask?.id,
                task_output: outputText
              }, '*')
            }
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
      const formattedError = formatPythonError(err.message)
      setOutput('Error: ' + formattedError)
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
        
        {/* Play as Guest button
        <div className="guest-login-container">
          <button
            onClick={() => {
              setCurrentAppUser(null)
              currentAppUserRef.current = null
              setAppView('main')
              // Show tutorial popup when playing as guest
              setShowTutorial(true)
              setOutput('Playing as guest')
            }}
            className="guest-login-button"
          >
            Skip Login - Play as Guest
          </button>
        </div> */}
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

            // Load user's trainer (should be the one just created)
            const userTrainers = await loadTrainers(data.id)
            if (userTrainers.length > 0) {
              const trainer = userTrainers[0]
              setCurrentTrainer(trainer)
              currentTrainerRef.current = trainer
              
              // Initialize user stats and login streak for new user
              await initializeUserStats(data.id, trainer.id)
              await updateLoginStreak(data.id, trainer.id)
              
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
    // Commented out to skip dashboard screen - go directly to game
    // return (
    //   <DashboardView
    //     username={currentAppUser?.username}
    //     onEnterGame={() => {
    //       setAppView('main')
    //       // Show tutorial popup when entering game
    //       setShowTutorial(true)
    //       // Don't send trainer yet - wait for GAME_STARTED signal from Godot
    //       setOutput('Game loading... Press ENTER to start.')
    //     }}
    //     onLogout={async () => {
    //       // End usage session before logout
    //       if (usageSession.sessionActive) {
    //         await usageSession.endSession()
    //       }
    //       setCurrentAppUser(null)
    //       currentAppUserRef.current = null
    //       setCurrentTrainer(null)
    //       setAppView('welcome')
    //       setOutput('👋 Logged out')
    //     }}
    //   />
    // )
    
    // Skip dashboard and go directly to game
    setAppView('main')
    setShowTutorial(true)
    setOutput('Game loading... Press ENTER to start.')
  }

  // Main game view (the existing game UI)
  return (
    <div className="app-container with-user-bar">
      {/* User Info Bar */}
      <div className="user-info-bar">
        <span className="trainer-username">
          {currentAppUser ? (
            <>
              <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" style={{ display: 'inline-block', verticalAlign: 'middle', marginRight: '8px' }}>
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                <circle cx="12" cy="7" r="4"></circle>
              </svg>
              {currentAppUser.username}
              {currentTrainer?.team && (
                <span style={{ 
                  marginLeft: '10px', 
                  color: currentTrainer.team === 'red' ? '#dc2626' : currentTrainer.team === 'blue' ? '#2563eb' : '#eddd00ff',
                  fontWeight: 'bold',
                  textTransform: 'capitalize'
                }}>
                  Team {currentTrainer.team}
                </span>
              )}
              {currentTrainer?.total_points !== undefined && (
                <span style={{ marginLeft: '10px', color: '#fbbf24', fontWeight: 'bold' }}>
                  ⭐ {currentTrainer.total_points}
                </span>
              )}
            </>
          ) : 'Playing as Guest'}
        </span>
        <div className="user-bar-buttons">
          {currentAppUser && (
            <>
              <button
                onClick={() => setShowMilestones(true)}
                className="milestones-button"
              >
                Achievements
              </button>
              <button
                onClick={() => setShowIndividualLeaderboard(true)}
                className="tutorial-button"
              >
                Leaderboard
              </button>
            </>
          )}
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
          <button
            onClick={() => setShowTutorial(true)}
            className="tutorial-button"
            style={{ background: '#38a169' }}
          >
            Tutorial
          </button>
          <button
            onClick={() => setShowVolunteer(true)}
            className="tutorial-button"
            style={{ background: '#38a169' }}
          >
            Volunteer
          </button>
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
          <div className="game-header">
            <h3>PyMon - Creature Collector</h3>
            <button 
              className="mute-button"
              onClick={() => {
                const iframe = document.querySelector('.game-frame') as HTMLIFrameElement;
                if (iframe) {
                  // Toggle mute state
                  const newMuteState = !isMuted;
                  setIsMuted(newMuteState);
                  
                  // Try to control iframe audio by setting audio attribute
                  if (newMuteState) {
                    iframe.contentWindow?.postMessage({ type: 'MUTE_AUDIO' }, '*');
                  } else {
                    iframe.contentWindow?.postMessage({ type: 'UNMUTE_AUDIO' }, '*');
                  }
                  
                  // Also try to mute all audio elements in the iframe
                  try {
                    const iframeDoc = iframe.contentDocument || iframe.contentWindow?.document;
                    if (iframeDoc) {
                      const audioElements = iframeDoc.querySelectorAll('audio, video');
                      audioElements.forEach((audio: any) => {
                        audio.muted = newMuteState;
                      });
                    }
                  } catch (e) {
                    console.log('Cannot access iframe content (CORS):', e);
                  }
                }
              }}
              title={isMuted ? "Unmute" : "Mute"}
            >
              {isMuted ? '🔇' : '🔊'}
            </button>
          </div>
          <iframe 
            src="/PyMon/game/web/Pokemon_Clone.html"
            width="100%"
            height="100%"
            title="Pokemon Clone Game"
            className="game-frame"
            onLoad={() => {
              console.log('Game iframe loaded, waiting for GAME_STARTED signal...')
              setOutput('Press ENTER in game to start')
              
              // Send initial mute state to game with retries to ensure it's received
              const iframe = document.querySelector('.game-frame') as HTMLIFrameElement;
              if (iframe && iframe.contentWindow) {
                const sendMuteState = () => {
                  const message = isMuted ? { type: 'MUTE_AUDIO' } : { type: 'UNMUTE_AUDIO' };
                  iframe.contentWindow?.postMessage(message, '*');
                };
                
                // Send multiple times with delays to ensure game receives it
                setTimeout(sendMuteState, 100);
                setTimeout(sendMuteState, 500);
                setTimeout(sendMuteState, 1000);
              }
            }}
            // allow="fullscreen"
          />
        </div>

        {/* Team Leaderboard Section */}
        <TeamLeaderboardPanel key={leaderboardRefreshKey} />
      </div>

      {/* Right Side - Python Editor Only */}
      <div className="right-panel">
        {/* Python Editor Section - Compact */}
        <div className="python-section-compact">
          <h3>Python Editor</h3>
          
          {/* Game Status Indicator */}
          {/* <div className={`game-status-indicator ${gameStatus === 'battle' ? 'game-status-battle' : 'game-status-roaming'}`}>
            {gameStatus === 'battle' ? 'IN BATTLE' : 'ROAMING'}
          </div> */}
          
          <div className="code-editor-wrapper" ref={syntaxHighlighterRef}>
            <div>
              <SyntaxHighlighter
                language="python"
                style={vscDarkPlus}
                customStyle={{
                  margin: 0,
                  padding: '16px',
                  borderRadius: '4px',
                  fontSize: '16px',
                  lineHeight: '1.4',
                  background: 'transparent',
                }}
                showLineNumbers={true}
                wrapLines={false}
                lineNumberStyle={{ 
                  minWidth: '3em', 
                  paddingRight: '1em', 
                  color: '#858585',
                  userSelect: 'none',
                  textAlign: 'right'
                }}
              >
                {code}
              </SyntaxHighlighter>
            </div>
            <textarea
              ref={textareaRef}
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

          {/* Hints Terminal - Shows exploration tips */}
          {currentHint && (
            <pre className="python-hints-terminal">
              <span key={currentHintIndex}>{currentHint}</span>
            </pre>
          )}
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

      {/* Tutorial Modal */}
      {showTutorial && (
        <div className="tutorial-modal-overlay" onClick={() => setShowTutorial(false)}>
          <div className="tutorial-modal-content" onClick={(e) => e.stopPropagation()}>
            <h2 className="tutorial-heading">Tutorial</h2>
            <button onClick={() => setShowTutorial(false)} className="tutorial-close-button">X</button>
            <img src="/PyMon/TutorialPage.png" alt="Tutorial" className="tutorial-image" />
          </div>
        </div>
      )}

      {/* Individual Leaderboard Modal */}
      <IndividualLeaderboardModal 
        show={showIndividualLeaderboard}
        onClose={() => setShowIndividualLeaderboard(false)}
        currentUserId={currentAppUser?.id || null}
      />

      {/* Volunteer Modal */}
      <VolunteerModal 
        show={showVolunteer}
        onClose={() => setShowVolunteer(false)}
      />
    </div>
  )
}

export default App 
