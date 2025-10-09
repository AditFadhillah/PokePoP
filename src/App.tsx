import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [battleCount, setBattleCount] = useState(0)
  const [lastBattleResult, setLastBattleResult] = useState<string>('')
  
  // Python Editor States
  const [pyodide, setPyodide] = useState<any>(null)
  const [code, setCode] = useState(`print("Hello from Python!")`)
  const [output, setOutput] = useState('')

  // Load Pyodide once
  useEffect(() => {
    const load = async () => {
      const pyodideInstance = await (window as any).loadPyodide()
      setPyodide(pyodideInstance)
      setOutput('✅ Pyodide loaded')
    }
    load()
  }, [])

  useEffect(() => {
    // Listen for messages from the Pokemon game iframe
    const handleMessage = (event: MessageEvent) => {
      // Make sure the message is from our game
      if (event.data && event.data.type === 'pokemon_battle_ended') {
        setBattleCount(prev => prev + 1)
        setLastBattleResult(event.data.result)
        console.log('Battle ended with result:', event.data.result)
      }
    }

    window.addEventListener('message', handleMessage)
    
    // Cleanup listener on component unmount
    return () => {
      window.removeEventListener('message', handleMessage)
    }
  }, [])

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
      setOutput(outputText || '✅ No output')
    } catch (err: any) {
      setOutput('❌ Error: ' + err.message)
    }
  }

  return (
    <div className="app-container">
      {/* Game Section - Left Side */}
      <div className="game-section">
        <h2>Pokemon Clone</h2>
        <iframe 
          src="https://godot-web-export-poke.vercel.app/Pokemon_Clone.html"
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
            rows={6}
            placeholder="Write your Python code here..."
            className="python-textarea-compact"
          />

          <button onClick={runPythonCode} className="run-button-compact">
            ▶️ Run
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
"// deploy" 
