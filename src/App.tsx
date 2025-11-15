import { useState, useEffect, useRef } from 'react'
import './App.css'
import { usePyodide } from './lib/usepyodide'
import { supabase, dbHelpers } from './lib/supabase'
import { Auth } from './components/Auth'

function App() {
  // Python Editor States
  const [pyodide, setPyodide] = useState<any>(null)
  const [code, setCode] = useState(`print("CATERPIE")\n# Try any Pokemon: BULBASAUR, CATERPIE, EEVEE, PIDGEY, VULPIX, RATTATA`)
  const [output, setOutput] = useState('')
  const [gameStatus, setGameStatus] = useState('menu') // 'menu', 'battle', 'unknown'

  // Trainer/Pokemon Inventory States
  const [currentTrainer, setCurrentTrainer] = useState<any>(null)
  const currentTrainerRef = useRef<any>(null)
  const [pokemonInventory, setPokemonInventory] = useState<any[]>([])
  const [totalPoints, setTotalPoints] = useState(0)
  const [allTrainers, setAllTrainers] = useState<any[]>([])
  const [isAuthenticated, setIsAuthenticated] = useState(false)

  // Supabase Database Functions
  
  // Load all trainers from database
  async function loadTrainers() {
    try {
      const { data, error } = await dbHelpers.getUserTrainers()
      
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
      
      // Calculate total points
      const points = trainerPokemon.reduce((sum, pokemon) => sum + parseInt(pokemon.points.toString()), 0)
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
      sendTrainerToGame(trainer.name)
      sendPokemonInventoryToGame(pokemonData)
      
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
    // Check authentication status
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      setIsAuthenticated(true)
      // Load trainers for this user
      const trainers = await loadTrainers()
      setAllTrainers(trainers)
      
      if (trainers.length > 0) {
        setOutput(`✅ Connected to database. Found ${trainers.length} trainer(s). Select one to start!`)
      } else {
        setOutput('⚠️ No trainers found. You may need to create trainers in your database.')
      }
    } else {
      setIsAuthenticated(false)
      // Load all trainers (development mode - not authenticated)
      const trainers = await loadTrainers()
      setAllTrainers(trainers)
      
      if (trainers.length > 0) {
        setOutput(`🔓 Development Mode: Found ${trainers.length} trainer(s) in database. Select one to start!`)
      } else {
        setOutput('⚠️ No trainers found in database. Please run the migration script.')
      }
    }
  }

  function handleGodotMessage(data: any) {
    if (data.type === 'BATTLE_STARTED') {
      setGameStatus('battle')
      setCode('print("in battle")')
      setOutput('Battle started! Code updated automatically.')
    } else if (data.type === 'BATTLE_ENDED') {
      setGameStatus('menu')
      setCode(`print("Click Enter")`)
      setOutput('Battle ended! Code restored.')
    } else if (data.type === 'POKEMON_CAPTURED') {
      handlePokemonCapture(data)
    } else if (data.type === 'request_current_trainer') {
      // Send current trainer to Godot, or load CSV data if no trainer exists
      if (currentTrainer) {
        sendTrainerToGame(currentTrainer.name)
        if (pokemonInventory.length > 0) {
          sendPokemonInventoryToGame(pokemonInventory)
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
      captured_at: captureData.data?.captured_at || captureData.captured_at || new Date().toISOString()
    }

    // Add to database using trainer from ref/state
    const success = await addPokemonToDatabase(trainer.id, pokemonData)
    
    if (success) {
      setOutput(`${pokemonData.name} (Lv.${pokemonData.level}) captured and saved to database! +${pokemonData.points} points`)
      
      // Refresh the inventory display
      await loadPokemonInventory(trainer.id)
      
      // Send updated inventory to game
      const updatedInventory = await loadPokemonInventory(trainer.id)
      sendPokemonInventoryToGame(updatedInventory)
    } else {
      setOutput(`${pokemonData.name} captured in game, but failed to save to database. Check console for details. (Hint: You may need to disable RLS in Supabase)`)
    }
  }

  // Add Pokemon to Supabase database
  async function addPokemonToDatabase(trainerId: string, pokemonData: {
    name: string,
    level: number,
    points: number,
    captured_at: string
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
            captured_at: pokemonData.captured_at
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
      
      // Get current trainer's total points and update
      const { data: trainerData } = await supabase
        .from('trainers')
        .select('total_points')
        .eq('id', trainerId)
        .single()
      
      const currentPoints = trainerData?.total_points || 0
      
      // Update trainer's total points
      const { error: updateError } = await supabase
        .from('trainers')
        .update({ 
          total_points: currentPoints + pokemonData.points,
          updated_at: new Date().toISOString()
        })
        .eq('id', trainerId)
      
      if (updateError) {
        console.error('Error updating trainer points:', updateError)
      }
      
      return true
    } catch (error) {
      console.error('Error adding Pokemon to database:', error)
      return false
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
      
      // Check for any Pokemon names
      const pokemon_pool = ["BULBASAUR", "CATERPIE", "EEVEE", "PIDGEY", "VULPIX", "RATTATA"]
      const foundPokemon = pokemon_pool.find(pokemon => 
        outputText && outputText.toUpperCase().includes(pokemon)
      )
      
      // Check if output contains "Click Enter" and send signal to game
      if (outputText && outputText.toLowerCase().includes('click enter')) {
        sendEnterToGame()
      }
      
      // Check if output contains any Pokemon name and send test Pokemon signal to game
      if (foundPokemon) {
        sendTestPokemonToGame(outputText.trim())
      }
    } catch (err: any) {
      setOutput('Error: ' + err.message)
    }
  }

  function sendEnterToGame() {
    const gameFrame = document.querySelector('.game-frame') as HTMLIFrameElement
    
    if (gameFrame && gameFrame.contentWindow) {
      const message = {
        type: 'PRESS_ENTER',
        action: 'key_press',
        key: 'enter'
      }
      gameFrame.contentWindow.postMessage(message, '*')
    }
  }

  function sendTestPokemonToGame(pokemonText: string) {
    const gameFrame = document.querySelector('.game-frame') as HTMLIFrameElement
    
    if (gameFrame && gameFrame.contentWindow) {
      const message = {
        type: 'TEST_POKEMON',
        pokemon_text: pokemonText
      }
      gameFrame.contentWindow.postMessage(message, '*')
    }
  }

  function sendTrainerToGame(trainerName: string) {
    const gameFrame = document.querySelector('.game-frame') as HTMLIFrameElement
    if (gameFrame && gameFrame.contentWindow) {
      gameFrame.contentWindow.postMessage({
        type: 'TRAINER_SELECTED',
        trainer_name: trainerName
      }, '*')
    }
  }

  function sendPokemonInventoryToGame(pokemonData: any[]) {
    const gameFrame = document.querySelector('.game-frame') as HTMLIFrameElement
    if (gameFrame && gameFrame.contentWindow) {
      gameFrame.contentWindow.postMessage({
        type: 'POKEMON_INVENTORY_UPDATE',
        pokemon_data: pokemonData
      }, '*')
    }
  }

  return (
    <div className="app-container">
      {/* Left Side - Game + Trainer Management */}
      <div className="left-panel">
        {/* Game Section */}
        <div className="game-section">
          <h3 style={{ color: '#ffffff', marginTop: 0 }}>Creature Collector</h3>
          <iframe 
            src="/PokePoP/game/web/Pokemon_Clone.html"
            width="100%"
            height="100%"
            title="Pokemon Clone Game"
            className="game-frame"
            onLoad={() => {
              // Wait for game initialization, then send current trainer
              setTimeout(() => {
                if (currentTrainer) {
                  sendTrainerToGame(currentTrainer.name)
                }
              }, 2000)
            }}
            // allow="fullscreen"
          />
        </div>

        {/* Trainer Management Section */}
        <div className="trainer-section" style={{
          padding: '15px',
          backgroundColor: '#2d3748',
          borderRadius: '8px',
          border: '1px solid #4a5568'
        }}>
          <h3 style={{ color: '#ffffff', marginTop: 0 }}>Trainer Management (Database)</h3>
          
          {/* Optional: Add authentication UI */}
          {/* Uncomment to enable sign in/sign up */}
          {/* <Auth /> */}
          
          <div style={{
            padding: '10px',
            marginBottom: '15px',
            backgroundColor: '#1a202c',
            borderRadius: '4px',
            border: '1px solid #4a5568',
            color: '#63b3ed',
            fontSize: '12px'
          }}>
            🎮 <strong>Select a trainer and start capturing Pokémon!</strong>
          </div>
          
          {/* Trainer Selection Buttons */}
          <div style={{ marginBottom: '15px' }}>
            <h4 style={{ color: '#ffffff', marginBottom: '10px' }}>Select Trainer:</h4>
            <div style={{ display: 'flex', gap: '10px', marginBottom: '10px', flexWrap: 'wrap' }}>
              <button 
                onClick={async () => {
                  const trainers = await loadTrainers()
                  if (trainers.length > 0) {
                    const trainer = trainers[0]
                    setCurrentTrainer(trainer)
                    currentTrainerRef.current = trainer
                    const pokemonData = await loadPokemonInventory(trainer.id)
                    sendTrainerToGame(trainer.name)
                    sendPokemonInventoryToGame(pokemonData)
                    setOutput(`✅ ${trainer.name} selected with ${pokemonData.length} Pokemon. Ready to capture!`)
                  } else {
                    setOutput('❌ No trainers found in database. Please create a trainer first.')
                  }
                }}
                style={{
                  padding: '10px 20px',
                  backgroundColor: currentTrainer?.id === (async () => (await loadTrainers())[0]?.id)() ? '#4CAF50' : '#4a5568',
                  color: 'white',
                  border: 'none',
                  borderRadius: '4px',
                  cursor: 'pointer',
                  fontWeight: 'bold'
                }}
              >
                👤 Trainer 1
              </button>
              
              <button 
                onClick={async () => {
                  const trainers = await loadTrainers()
                  if (trainers.length > 1) {
                    const trainer = trainers[1]
                    setCurrentTrainer(trainer)
                    currentTrainerRef.current = trainer
                    const pokemonData = await loadPokemonInventory(trainer.id)
                    sendTrainerToGame(trainer.name)
                    sendPokemonInventoryToGame(pokemonData)
                    setOutput(`✅ ${trainer.name} selected with ${pokemonData.length} Pokemon. Ready to capture!`)
                  } else {
                    setOutput('❌ Less than 2 trainers found in database.')
                  }
                }}
                style={{
                  padding: '10px 20px',
                  backgroundColor: currentTrainer?.id === (async () => (await loadTrainers())[1]?.id)() ? '#4CAF50' : '#4a5568',
                  color: 'white',
                  border: 'none',
                  borderRadius: '4px',
                  cursor: 'pointer',
                  fontWeight: 'bold'
                }}
              >
                👤 Trainer 2
              </button>
            </div>
          </div>
          
          {/* Current Trainer Display */}
          {currentTrainer && (
            <div style={{
              padding: '10px',
              marginBottom: '15px',
              backgroundColor: '#1a202c',
              borderRadius: '4px',
              border: '1px solid #4a5568'
            }}>
              <h4 style={{ color: '#ffffff', marginTop: 0 }}>Current Trainer: {currentTrainer.name}</h4>
              <p style={{ color: '#a0aec0', margin: '5px 0' }}>Total Points: {totalPoints}</p>
              <p style={{ color: '#a0aec0', margin: '5px 0' }}>Pokémon Count: {pokemonInventory.length}</p>
            </div>
          )}
          
          {/* Warning when no trainer selected */}
          {!currentTrainer && (
            <div style={{
              padding: '10px',
              marginBottom: '15px',
              backgroundColor: '#742a2a',
              borderRadius: '4px',
              border: '1px solid #fc8181',
              color: '#feb2b2'
            }}>
              ⚠️ <strong>No trainer selected!</strong> Please select a trainer above.
            </div>
          )}
          
          {/* Pokemon Inventory Display */}
          {pokemonInventory.length > 0 && (
            <div style={{ marginTop: '15px' }}>
              <h4 style={{ color: '#ffffff' }}>Pokémon Inventory:</h4>
              <div style={{ maxHeight: '150px', overflowY: 'auto' }}>
                {pokemonInventory.map((pokemon, index) => (
                  <div key={index} style={{
                    padding: '5px',
                    margin: '2px 0',
                    backgroundColor: '#1a202c',
                    borderRadius: '4px',
                    fontSize: '12px',
                    color: '#a0aec0'
                  }}>
                    {pokemon.pokemon_name} (Lv.{pokemon.level}) - {pokemon.points} pts
                  </div>
                ))}
              </div>
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
            {gameStatus === 'battle' ? 'IN BATTLE' : 'OVERWORLD'}
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
            ▶️ Evaluate Code
          </button>

          <pre className="python-output-compact">
            {output}
          </pre>
        </div>
      </div>
    </div>
  )
}

export default App 
