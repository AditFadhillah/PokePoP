import { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="app-container">
      {/* Game Section - Left Side */}
      <div className="game-section">
        <h2>Pokemon Clone</h2>
        <iframe 
          src="https://godot-web-export-poke.vercel.app/Pokemon_Clone.html"
          width="800"
          height="600"
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
        <div className="info-content">
          <h3>Game Features:</h3>
          <ul>
            <li>Classic Pokemon-style gameplay</li>
            <li>Built with Godot Engine</li>
            <li>Web-based HTML5 export</li>
          </ul>
        </div>
      </div>
    </div>
  )
}

export default App
"// deploy" 
