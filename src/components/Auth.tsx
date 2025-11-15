import { useState } from 'react'
import { supabase } from '../lib/supabase'

export function Auth() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')

  const handleSignUp = async () => {
    setLoading(true)
    setMessage('')
    
    const { error } = await supabase.auth.signUp({
      email,
      password,
    })
    
    if (error) {
      setMessage(`Error: ${error.message}`)
    } else {
      setMessage('✅ Sign up successful! Check your email to confirm.')
    }
    
    setLoading(false)
  }

  const handleSignIn = async () => {
    setLoading(true)
    setMessage('')
    
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    
    if (error) {
      setMessage(`Error: ${error.message}`)
    } else {
      setMessage('✅ Signed in successfully!')
      window.location.reload() // Reload to initialize with auth
    }
    
    setLoading(false)
  }

  const handleSignOut = async () => {
    await supabase.auth.signOut()
    window.location.reload()
  }

  return (
    <div style={{
      padding: '20px',
      backgroundColor: '#2d3748',
      borderRadius: '8px',
      marginBottom: '15px'
    }}>
      <h4 style={{ color: '#ffffff', marginTop: 0 }}>Authentication</h4>
      
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        style={{
          width: '100%',
          padding: '10px',
          marginBottom: '10px',
          borderRadius: '4px',
          border: '1px solid #4a5568',
          backgroundColor: '#1a202c',
          color: '#ffffff'
        }}
      />
      
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        style={{
          width: '100%',
          padding: '10px',
          marginBottom: '10px',
          borderRadius: '4px',
          border: '1px solid #4a5568',
          backgroundColor: '#1a202c',
          color: '#ffffff'
        }}
      />
      
      <div style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
        <button 
          onClick={handleSignIn}
          disabled={loading}
          style={{
            flex: 1,
            padding: '10px',
            backgroundColor: '#4CAF50',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: loading ? 'not-allowed' : 'pointer'
          }}
        >
          Sign In
        </button>
        
        <button 
          onClick={handleSignUp}
          disabled={loading}
          style={{
            flex: 1,
            padding: '10px',
            backgroundColor: '#2196F3',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: loading ? 'not-allowed' : 'pointer'
          }}
        >
          Sign Up
        </button>
        
        <button 
          onClick={handleSignOut}
          style={{
            padding: '10px 20px',
            backgroundColor: '#f44336',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Sign Out
        </button>
      </div>
      
      {message && (
        <div style={{
          padding: '10px',
          backgroundColor: '#1a202c',
          borderRadius: '4px',
          color: message.includes('Error') ? '#fc8181' : '#68d391',
          fontSize: '12px'
        }}>
          {message}
        </div>
      )}
    </div>
  )
}
