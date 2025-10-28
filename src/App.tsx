import { useState, useEffect } from 'react'
import './App.css'
import { supabase } from './lib/supabase'  // Re-enabled supabase lib 
import { usePyodide } from './lib/usepyodide' // Fixed import path

function App() {
  // Python Editor States
  const [pyodide, setPyodide] = useState<any>(null)
  const [code, setCode] = useState(`print("Click Enter")`)
  const [output, setOutput] = useState('')
  const [gameStatus, setGameStatus] = useState('menu') // 'menu', 'battle', 'unknown'

  // Trainer/Pokemon Inventory States
  const [currentTrainer, setCurrentTrainer] = useState<any>(null)
  const [trainerName, setTrainerName] = useState('')
  const [pokemonInventory, setPokemonInventory] = useState<any[]>([])
  const [totalPoints, setTotalPoints] = useState(0)
  const [allTrainers, setAllTrainers] = useState<any[]>([])

  // CSV Data Functions (for testing without database)
  
  // Parse CSV string into array of objects
  function parseCSV(csvText: string): any[] {
    const lines = csvText.trim().split('\n')
    const headers = lines[0].split(',')
    
    return lines.slice(1).map(line => {
      const values = line.split(',')
      const obj: any = {}
      headers.forEach((header, index) => {
        obj[header] = values[index]
      })
      return obj
    })
  }
  
  // Load CSV trainers
  async function loadCSVTrainers() {
    try {
      const response = await fetch('/test_trainer.csv')
      const csvText = await response.text()
      const trainers = parseCSV(csvText)
      
      console.log('Loaded CSV trainers:', trainers)
      setAllTrainers(trainers)
      return trainers
    } catch (error) {
      console.error('Error loading CSV trainers:', error)
      return []
    }
  }
  
  // Load CSV Pokemon inventory for a trainer
  async function loadCSVPokemonInventory(trainerId: string) {
    try {
      const response = await fetch('/test_pokemon_inventory.csv')
      const csvText = await response.text()
      const allPokemon = parseCSV(csvText)
      
      // Filter Pokemon for this trainer
      const trainerPokemon = allPokemon.filter(p => p.trainer_id === trainerId)
      
      console.log('Loaded CSV Pokemon for trainer', trainerId, ':', trainerPokemon)
      setPokemonInventory(trainerPokemon)
      
      // Calculate total points
      const points = trainerPokemon.reduce((sum, pokemon) => sum + parseInt(pokemon.points), 0)
      setTotalPoints(points)
      
      return trainerPokemon
    } catch (error) {
      console.error('Error loading CSV Pokemon inventory:', error)
      return []
    }
  }
  
  // Get or select the test trainer from CSV
  async function getCSVTrainer() {
    const trainers = await loadCSVTrainers()
    if (trainers.length > 0) {
      const trainer = trainers[0] // Get the "tester" trainer
      setCurrentTrainer(trainer)
      setTrainerName(trainer.name)
      
      // Load their Pokemon
      await loadCSVPokemonInventory(trainer.id)
      
      // Send to game
      sendTrainerToGame(trainer.name)
      
      console.log('Selected CSV trainer:', trainer)
      return trainer
    }
    return null
  } 
  const pyodideInstance = usePyodide()
  useEffect(() => {
    if (pyodideInstance) {
      setPyodide(pyodideInstance)
      setOutput('Pyodide loaded')
    }

    // Listen for messages from Godot
    const handleMessage = (event: MessageEvent) => {
      console.log('React received message:', event)
      if (event.data && event.data.type === 'GODOT_MESSAGE') {
        console.log('Received message from Godot:', event.data)
        handleGodotMessage(event.data.data)
      }
    }

    window.addEventListener('message', handleMessage)
    
    // Cleanup
    return () => {
      window.removeEventListener('message', handleMessage)
    }
  }, [pyodideInstance])

  // Database functions for Trainer/Pokemon system
  
  // Create or get trainer
  async function createOrGetTrainer(name: string) {
    const { data: { user }, error: userErr } = await supabase.auth.getUser()
    if (userErr || !user) { 
      console.error(userErr || 'No user')
      return null
    }

    try {
      // First check if trainer exists
      const { data: existingTrainer, error: _fetchError } = await supabase
        .from('trainers')
        .select('*')
        .eq('user_id', user.id)
        .eq('name', name)
        .single()

      if (existingTrainer) {
        setCurrentTrainer(existingTrainer)
        setTrainerName(existingTrainer.name)
        await loadTrainerInventory(existingTrainer.id)
        
        // Send trainer data to Godot game
        sendTrainerToGame(existingTrainer.name)
        
        return existingTrainer
      }

      // Create new trainer if doesn't exist
      const { data: newTrainer, error: createError } = await supabase
        .from('trainers')
        .insert([
          { 
            user_id: user.id, 
            name: name,
            total_points: 0,
            created_at: new Date().toISOString()
          }
        ])
        .select()
        .single()

      if (createError) {
        console.error('Error creating trainer:', createError)
        return null
      }

      setCurrentTrainer(newTrainer)
      setTrainerName(newTrainer.name)
      setTotalPoints(0)
      setPokemonInventory([])
      
      // Send trainer data to Godot game
      sendTrainerToGame(newTrainer.name)
      
      return newTrainer
    } catch (error) {
      console.error('Error in createOrGetTrainer:', error)
      return null
    }
  }

  // Load trainer's Pokemon inventory
  async function loadTrainerInventory(trainerId: string) {
    try {
      const { data: inventory, error } = await supabase
        .from('pokemon_inventory')
        .select('*')
        .eq('trainer_id', trainerId)
        .order('captured_at', { ascending: false })

      if (error) {
        console.error('Error loading inventory:', error)
        return
      }

      setPokemonInventory(inventory || [])
      
      // Calculate total points
      const points = inventory?.reduce((sum, pokemon) => sum + pokemon.points, 0) || 0
      setTotalPoints(points)
    } catch (error) {
      console.error('Error in loadTrainerInventory:', error)
    }
  }

  // Add Pokemon to trainer's inventory
  async function addPokemonToInventory(trainerId: string, pokemonData: {
    name: string,
    level: number,
    points: number
  }) {
    try {
      const { error } = await supabase
        .from('pokemon_inventory')
        .insert([
          {
            trainer_id: trainerId,
            pokemon_name: pokemonData.name,
            level: pokemonData.level,
            points: pokemonData.points,
            captured_at: new Date().toISOString()
          }
        ])
        .select()

      if (error) {
        console.error('Error adding Pokemon:', error)
        return false
      }

      // Update trainer's total points
      const newPoints = totalPoints + pokemonData.points
      await updateTrainerPoints(trainerId, newPoints)
      
      // Refresh inventory
      await loadTrainerInventory(trainerId)
      return true
    } catch (error) {
      console.error('Error in addPokemonToInventory:', error)
      return false
    }
  }

  // Update trainer's total points
  async function updateTrainerPoints(trainerId: string, newPoints: number) {
    try {
      const { error } = await supabase
        .from('trainers')
        .update({ total_points: newPoints })
        .eq('id', trainerId)

      if (error) {
        console.error('Error updating trainer points:', error)
      }
    } catch (error) {
      console.error('Error in updateTrainerPoints:', error)
    }
  }

  // Get all trainers (leaderboard)
  async function loadAllTrainers() {
    try {
      const { data: trainers, error } = await supabase
        .from('trainers')
        .select(`
          *,
          pokemon_inventory(count)
        `)
        .order('total_points', { ascending: false })

      if (error) {
        console.error('Error loading trainers:', error)
        return []
      }

      setAllTrainers(trainers || [])
      return trainers || []
    } catch (error) {
      console.error('Error in loadAllTrainers:', error)
      return []
    }
  }

  // Retesting connection to DB 
  const [count, setCount] = useState(0)
  const [ok, setOk] = useState('checking…') // Added new state for checking database connection 

  // testing store count method 
  async function updateCountInDB(newCount: number) {
    const { data: { user }, error: userErr } = await supabase.auth.getUser()
    if (userErr || !user) { console.error(userErr || 'No user'); return }

    const { error } = await supabase
      .from('testcount') // or 'test_count' — match your actual table name
      .upsert([{ id: user.id, totalcount: newCount }])

    if (error) console.error('DB upsert error:', error)
  }

  // method for testing data connection 
  useEffect(() => {
    (async () => {
      // Optional: create an anonymous session if none exists
      const { data: { session } } = await supabase.auth.getSession()
      if (!session) {
        const { error } = await supabase.auth.signInAnonymously()
        if (error) return setOk('error: ' + error.message)
      }

      // Now report the current session state
      const { data: { session: s }, error } = await supabase.auth.getSession()
      if (error) setOk('error: ' + error.message)
      else setOk(s ? 'session exists' : 'no session yet')
    })()
  }, [])

  // Initialize trainers when app loads
  useEffect(() => {
    initializeApp()
  }, [])

  async function initializeApp() {
    console.log('Initializing app with CSV data...')
    
    // Load CSV trainer data instead of database
    const trainer = await getCSVTrainer()
    
    if (trainer) {
      console.log('Successfully loaded CSV trainer:', trainer.name)
      setOutput(`Loaded test trainer: ${trainer.name} with ${pokemonInventory.length} Pokemon`)
    } else {
      console.log('No CSV trainer found')
      setOutput('No test trainer found in CSV')
    }
  }

  function handleGodotMessage(data: any) {
    if (data.type === 'BATTLE_STARTED') {
      console.log('Battle started! Updating Python code...')
      setGameStatus('battle')
      setCode('print("in battle")')
      setOutput('Battle started! Code updated automatically.')
    } else if (data.type === 'BATTLE_ENDED') {
      console.log('Battle ended! Restoring Python code...')
      setGameStatus('menu')
      setCode(`# Test the game communication
print("Hello from Python!")
print("Click Enter")
print("This should trigger the game!")`)
      setOutput('Battle ended! Code restored.')
    } else if (data.type === 'POKEMON_CAPTURED') {
      console.log('Pokemon captured!', data)
      handlePokemonCapture(data)
    } else if (data.type === 'request_current_trainer') {
      console.log('Godot requesting current trainer')
      // Send current trainer to Godot
      if (currentTrainer) {
        sendTrainerToGame(currentTrainer.name)
      }
    }
  }

  // Handle Pokemon capture from Godot
  async function handlePokemonCapture(captureData: any) {
    if (!currentTrainer) {
      console.warn('No current trainer selected! Pokemon capture ignored.')
      setOutput('Warning: No trainer selected. Pokemon capture not saved to database.')
      return
    }

    const pokemonData = {
      name: captureData.pokemon_name || 'Unknown',
      level: captureData.level || 1,
      points: captureData.points || 100
    }

    console.log('Adding Pokemon to database:', pokemonData)
    const success = await addPokemonToInventory(currentTrainer.id, pokemonData)
    
    if (success) {
      setOutput(`${pokemonData.name} (Lv.${pokemonData.level}) captured and saved to database! +${pokemonData.points} points`)
    } else {
      setOutput(`${pokemonData.name} captured in game, but failed to save to database.`)
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
      setOutput(outputText || 'No output')
      
      // Check if output contains "Click Enter" and send signal to game
      if (outputText && outputText.toLowerCase().includes('click enter')) {
        sendEnterToGame()
      }
    } catch (err: any) {
      setOutput('Error: ' + err.message)
    }
  }

  function sendEnterToGame() {
    // Get the iframe element
    const gameFrame = document.querySelector('.game-frame') as HTMLIFrameElement
    if (gameFrame && gameFrame.contentWindow) {
      // Send a message to the Godot game
      gameFrame.contentWindow.postMessage({
        type: 'PRESS_ENTER',
        action: 'key_press',
        key: 'enter'
      }, '*')
      console.log('Sent ENTER signal to game!')
    }
  }

  function sendTrainerToGame(trainerName: string) {
    // Send trainer data to Godot game
    const gameFrame = document.querySelector('.game-frame') as HTMLIFrameElement
    if (gameFrame && gameFrame.contentWindow) {
      gameFrame.contentWindow.postMessage({
        type: 'TRAINER_SELECTED',
        trainer_name: trainerName
      }, '*')
      console.log('Sent trainer data to game:', trainerName)
    } else {
      console.warn('Game frame not found or not ready')
    }
  }

  return (
    <div className="app-container">
      {/* Game Section - Left Side */}
      <div className="game-section">
        <h2>Creature Collector</h2>
        <iframe 
          src="/PokePoP/game/web/Pokemon_Clone.html"
          width="100%"
          height="100%"
          title="Pokemon Clone Game"
          className="game-frame"
          onLoad={() => {
            console.log('Game iframe loaded')
            // Wait a bit for the game to initialize, then send current trainer
            setTimeout(() => {
              if (currentTrainer) {
                sendTrainerToGame(currentTrainer.name)
                console.log('Sent current trainer to newly loaded game:', currentTrainer.name)
              }
            }, 2000)
          }}
          onError={() => {
            console.error('Game iframe failed to load')
          }}
          // allow="fullscreen"
        />
      </div>

      
      {/* Right Side - Python Editor */}
      <div className="right-panel">
        
        {/* Trainer Management Section */}
        <div className="trainer-section" style={{
          marginBottom: '20px',
          padding: '15px',
          backgroundColor: '#f5f5f5',
          borderRadius: '8px',
          border: '1px solid #ddd'
        }}>
          <h3>Trainer Management (CSV Test Mode)</h3>
          
          <div style={{
            padding: '10px',
            marginBottom: '15px',
            backgroundColor: '#e3f2fd',
            borderRadius: '4px',
            border: '1px solid #2196F3',
            color: '#1976d2',
            fontSize: '12px'
          }}>
            📊 <strong>Testing with CSV data:</strong> Trainer "tester" with 1 PIDGEY (Lv.2, 200pts)
          </div>
          
          {/* Warning when no trainer selected */}
          {!currentTrainer && (
            <div style={{
              padding: '10px',
              marginBottom: '15px',
              backgroundColor: '#fff3cd',
              borderRadius: '4px',
              border: '1px solid #ffeaa7',
              color: '#856404'
            }}>
              ⚠️ <strong>No trainer selected!</strong> Pokémon captures won't be saved to database.
            </div>
          )}
          
          {!currentTrainer ? (
            <div>
              <input
                type="text"
                placeholder="Enter trainer name"
                value={trainerName}
                onChange={(e) => setTrainerName(e.target.value)}
                style={{
                  padding: '8px',
                  marginRight: '10px',
                  borderRadius: '4px',
                  border: '1px solid #ccc'
                }}
              />
              <button 
                onClick={() => createOrGetTrainer(trainerName)}
                disabled={!trainerName.trim()}
                style={{
                  padding: '8px 15px',
                  backgroundColor: '#4CAF50',
                  color: 'white',
                  border: 'none',
                  borderRadius: '4px',
                  cursor: 'pointer'
                }}
              >
                Create/Load Trainer
              </button>
            </div>
          ) : (
            <div>
              <h4>Current Trainer: {currentTrainer.name}</h4>
              <p>Total Points: {totalPoints}</p>
              <p>Pokémon Count: {pokemonInventory.length}</p>
              
              {/* Test: Add random Pokemon */}
              <button 
                onClick={() => {
                  const pokemon_pool = ["BULBASAUR", "CATERPIE", "EEVEE", "PIDGEY", "VULPIX"]
                  const randomLevel = Math.floor(Math.random() * 3) + 1 // Level 1-3
                  const testPokemon = {
                    name: pokemon_pool[Math.floor(Math.random() * pokemon_pool.length)],
                    level: randomLevel,
                    points: randomLevel * 100 // Same calculation as Godot: level * 100
                  }
                  addPokemonToInventory(currentTrainer.id, testPokemon)
                }}
                style={{
                  padding: '5px 10px',
                  backgroundColor: '#2196F3',
                  color: 'white',
                  border: 'none',
                  borderRadius: '4px',
                  cursor: 'pointer',
                  marginRight: '10px'
                }}
              >
                Add Test Pokémon
              </button>
              
              <button 
                onClick={() => {
                  setCurrentTrainer(null)
                  setTrainerName('')
                  setPokemonInventory([])
                  setTotalPoints(0)
                }}
                style={{
                  padding: '5px 10px',
                  backgroundColor: '#f44336',
                  color: 'white',
                  border: 'none',
                  borderRadius: '4px',
                  cursor: 'pointer',
                  marginRight: '10px'
                }}
              >
                Switch Trainer
              </button>
              
              <button 
                onClick={() => {
                  if (currentTrainer) {
                    sendTrainerToGame(currentTrainer.name)
                    setOutput(`Sent trainer "${currentTrainer.name}" to game`)
                  }
                }}
                style={{
                  padding: '5px 10px',
                  backgroundColor: '#9C27B0',
                  color: 'white',
                  border: 'none',
                  borderRadius: '4px',
                  cursor: 'pointer'
                }}
              >
                Test Send to Game
              </button>
            </div>
          )}
          
          {/* Pokemon Inventory Display */}
          {pokemonInventory.length > 0 && (
            <div style={{ marginTop: '15px' }}>
              <h4>Pokémon Inventory:</h4>
              <div style={{ maxHeight: '150px', overflowY: 'auto' }}>
                {pokemonInventory.map((pokemon, index) => (
                  <div key={index} style={{
                    padding: '5px',
                    margin: '2px 0',
                    backgroundColor: 'white',
                    borderRadius: '4px',
                    fontSize: '12px'
                  }}>
                    {pokemon.pokemon_name} (Lv.{pokemon.level}) - {pokemon.points} pts
                  </div>
                ))}
              </div>
            </div>
          )}
          
          {/* Leaderboard */}
          <div style={{ marginTop: '15px' }}>
            <button 
              onClick={loadAllTrainers}
              style={{
                padding: '5px 10px',
                backgroundColor: '#FF9800',
                color: 'white',
                border: 'none',
                borderRadius: '4px',
                cursor: 'pointer'
              }}
            >
              Load Leaderboard
            </button>
            
            {allTrainers.length > 0 && (
              <div style={{ marginTop: '10px' }}>
                <h5>Top Trainers:</h5>
                <div style={{ maxHeight: '100px', overflowY: 'auto', fontSize: '11px' }}>
                  {allTrainers.slice(0, 5).map((trainer, index) => (
                    <div key={trainer.id} style={{ padding: '2px 0' }}>
                      {index + 1}. {trainer.name} - {trainer.total_points} pts
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
        
        {/* Python Editor Section - Compact */}
        <div className="python-section-compact">
          <h3>Python Editor</h3>
          
          {/* Game Status Indicator */}
          <div style={{
            padding: '5px 10px',
            marginBottom: '10px',
            borderRadius: '5px',
            backgroundColor: gameStatus === 'battle' ? '#bd3a3aff' : '#37bc37ff',
            color: 'white',
            textAlign: 'center',
            fontSize: '12px',
            fontWeight: 'bold'
          }}>
            {gameStatus === 'battle' ? 'IN BATTLE' : 'MENU/OVERWORLD'}
          </div>
          
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
            rows={6}
            placeholder="Write your Python code here..."
            className="python-textarea-compact"
          />


          <button onClick={runPythonCode} className="run-button-compact">
            ▶️ Run
          </button>

          {/* <button onClick={sendEnterToGame} className="run-button-compact" style={{marginLeft: '10px', backgroundColor: '#4CAF50'}}>
            Send Enter to Game
          </button> */}

          <pre className="python-output-compact">
            {output}
          </pre>
          <div>Supabase status: {ok}</div>  {/* Added for checking status */}
          <div>Current trainer: {currentTrainer ? currentTrainer.name : 'None'}</div>
          <div>Messages received: {output}</div>
           <div className="card">
            <button onClick={async () => {
              const newCount = count + 1
              setCount(newCount) /* Added for stored count in database */
              await updateCountInDB(newCount)
            }}>
              test count is {count}
            </button>
            
            <button onClick={() => {
              console.log('=== DEBUGGING INFO ===')
              console.log('Current trainer:', currentTrainer)
              console.log('Game frame element:', document.querySelector('.game-frame'))
              console.log('All trainers:', allTrainers)
              console.log('Pokemon inventory:', pokemonInventory)
              setOutput('Check console for debug info')
            }} style={{marginLeft: '10px', backgroundColor: '#607D8B', color: 'white', padding: '8px', border: 'none', borderRadius: '4px'}}>
              Debug Info
            </button>
            
            <button onClick={async () => {
              setOutput('Loading CSV data...')
              const trainer = await getCSVTrainer()
              if (trainer) {
                setOutput(`✅ CSV data loaded! Trainer: ${trainer.name}, Pokemon: ${pokemonInventory.length}, Points: ${totalPoints}`)
              } else {
                setOutput('❌ Failed to load CSV data')
              }
            }} style={{marginLeft: '10px', backgroundColor: '#4CAF50', color: 'white', padding: '8px', border: 'none', borderRadius: '4px'}}>
              Load CSV Test Data
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App 
