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


  //iniitial state of pyodide 
  const pyodideInstance = usePyodide()
  useEffect(() => {
    if (pyodideInstance) {
      setPyodide(pyodideInstance)
      setOutput('✅ Pyodide loaded')
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
      console.log('🎮 Sent ENTER signal to game!')
    }
  }

  return (
    <div className="app-container">
      {/* Game Section - Left Side */}
      <div className="game-section">
        <h2>Pokemon Clone</h2>
        <iframe 
          src="/PokePoP/Pokemon_Clone.html"
          width="600"
          height="400"
          title="Pokemon Clone Game"
          className="game-frame"
          allow="fullscreen"
        />
      </div>

      
      {/* Right Side - Python Editor */}
      <div className="right-panel">
        
        {/* Python Editor Section - Compact */}
        <div className="python-section-compact">
          <h3>Python Editor</h3>
          
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


          <button
            /* onClick={async () => {
              if (!pyodide) return;
              try {
                const outputText = await runAndSavePython(pyodide, code, 'output.txt')
                setOutput(outputText || '✅ No output');
              } catch (err: any) {
                const errorMsg = '❌ Error: ' + err.message;
                setOutput(errorMsg);
              }
            }}
            className="run-button-compact"
            */

            onClick={async () => {
              if (!pyodide) return
              const outputText = await runPython(pyodide,code)
              setOutput(outputText)
            }}
          >
            ▶️ Run
          </button>

          <button onClick={sendEnterToGame} className="run-button-compact" style={{marginLeft: '10px', backgroundColor: '#4CAF50'}}>
            🎮 Send Enter to Game
          </button>

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
