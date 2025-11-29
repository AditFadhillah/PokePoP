import React from 'react'

type Props = {
  onOpenLogin: () => void
  children?: React.ReactNode
}

export default function WelcomeView({ onOpenLogin, children }: Props) {
  return (
    <div 
      className="app-container" 
      style={{ 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'center', 
        minHeight: '100vh',
        backgroundImage: 'url(/PyMon/Background_login.png)',
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundRepeat: 'no-repeat'
      }}
    >
      <div style={{ width: 380, padding: 24, border: '1px solid #ddd', borderRadius: 8, background: 'rgba(255, 255, 255, 0.95)', textAlign: 'center', boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)' }}>
        <h2 style={{ marginTop: 0 }}>Welcome</h2>
        <p style={{ color: '#555', marginTop: 0 }}>Please log in to continue.</p>
        <button
          onClick={onOpenLogin}
          style={{ padding: '10px 14px', backgroundColor: '#10b981', color: 'white', border: 'none', borderRadius: 6, cursor: 'pointer', width: '100%' }}
        >
          Login
        </button>
      </div>
      {children}
    </div>
  )
}
