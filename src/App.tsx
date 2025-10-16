import { useState, useEffect } from 'react'
import './App.css'
import { supabase } from './lib/supabase'  // added supabase lib 
import { usePyodide } from './lib/usepyodide' // added for include the editor 

// import store files modul 
import { runAndSavePython } from './lib/storeoutput'
import { runPython } from './lib/storeoutput'

function App() {
  // Python Editor States
  const [pyodide, setPyodide] = useState<any>(null)
  const [code, setCode] = useState(`# Test the game communication
print("Hello from Python!")
print("Click Enter")
print("This should trigger the game!")`)
  const [output, setOutput] = useState('')
  const [gameStatus, setGameStatus] = useState('menu') // 'menu', 'battle', 'unknown'

  //iniitial state of pyodide 
  const pyodideInstance = usePyodide()
  useEffect(() => {
    if (pyodideInstance) {
      setPyodide(pyodideInstance)
      setOutput('Pyodide loaded')
    }

    // Listen for messages from Godot
    const handleMessage = (event: MessageEvent) => {
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

  return (
    <div className="app-container">
      {/* Game Section - Left Side */}
      <div className="game-section">
        <h2>Creature Collector</h2>
        <iframe 
          src="/PokePoP/Pokemon_Clone.html"
          width="100%"
          height="100%"
          title="Pokemon Clone Game"
          className="game-frame"
          // allow="fullscreen"
        />
      </div>

      
      {/* Right Side - Python Editor */}
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
            🎮 Send Enter to Game
          </button> */}

          <pre className="python-output-compact">
            {output}
          </pre>
          <div>Supabase status: {ok}</div>  {/* Added for checking status */}
           <div className="card">
            <button onClick={async () => {
              const newCount = count + 1
              setCount(newCount) /* Added for stored count in database */
              await updateCountInDB(newCount)
            }}>
              test count is {count}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App 
