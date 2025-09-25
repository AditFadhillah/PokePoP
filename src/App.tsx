import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)
  const [battleCount, setBattleCount] = useState(0)
  const [lastBattleResult, setLastBattleResult] = useState<string>('')

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
      
      {/* Info Section - Right Side */}
      <div className="info-section">
        <h1>PokePoP</h1>
        <div className="card">
          <button onClick={() => setCount((count) => count + 1)}>
            count is {count}
          </button>
          <p>Play the Pokemon Clone game on the left!</p>
          <p>Click count: <strong>{count}</strong></p>
        </div>
        
        {/* Battle Counter Section */}
        <div className="battle-stats">
          <h3>Battle Statistics</h3>
          <div className="stat-item">
            <span className="stat-label">Battles Completed:</span>
            <span className="stat-value">{battleCount}</span>
          </div>
          {lastBattleResult && (
            <div className="stat-item">
              <span className="stat-label">Last Battle:</span>
              <span className={`stat-value result-${lastBattleResult}`}>
                {lastBattleResult === 'victory' ? '🏆 Victory!' : 
                 lastBattleResult === 'defeat' ? '💀 Defeat' : 
                 lastBattleResult === 'escaped' ? '🏃 Escaped' : lastBattleResult}
              </span>
            </div>
          )}
        </div>
        
        <div className="info-content">
          <h3>Game Features:</h3>
          <ul>
            <li>Classic Pokemon-style gameplay</li>
            <li>Built with Godot Engine</li>
            <li>Web-based HTML5 export</li>
            <li>Real-time battle tracking</li>
          </ul>
          
          <div className="instructions">
            <h4>How to trigger battle counter:</h4>
            <ol>
              <li>Walk around in the game</li>
              <li>Enter a wild Pokemon battle</li>
              <li>Win, lose, or run from the battle</li>
              <li>Watch the counter update above! 🎮</li>
            </ol>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
"// deploy" 
