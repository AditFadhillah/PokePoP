import React from 'react'

type Props = {
  username?: string
  onEnterGame: () => void
  onLogout: () => void
}

export default function DashboardView({ username, onEnterGame, onLogout }: Props) {
  return (
    <div className="app-container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '100vh' }}>
      <div style={{ width: 420, padding: 24, border: '1px solid #ddd', borderRadius: 8, background: '#fff', textAlign: 'center' }}>
        <h2 style={{ marginTop: 0 }}>Welcome{username ? `, ${username}` : ''}!</h2>
        <p style={{ color: '#555', marginTop: 0 }}>You are logged in. Continue to the game area.</p>
        <div style={{ display: 'flex', gap: 8, justifyContent: 'center' }}>
          <button onClick={onEnterGame} style={{ padding: '10px 14px', backgroundColor: '#2563eb', color: 'white', border: 'none', borderRadius: 6, cursor: 'pointer' }}>
            Enter Game
          </button>
          <button onClick={onLogout} style={{ padding: '10px 14px', backgroundColor: '#9ca3af', color: 'white', border: 'none', borderRadius: 6, cursor: 'pointer' }}>
            Log out
          </button>
        </div>
      </div>
    </div>
  )
}
