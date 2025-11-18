import React, { useState } from 'react'
import { supabase } from '../lib/databaseFunctions'

type Props = {
  onBack: () => void
  onSuccess: (username: string) => void
}

export default function SignupView({ onBack, onSuccess }: Props) {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError('')

    if (password !== confirmPassword) {
      setError('Passwords do not match')
      return
    }

    setLoading(true)

    try {
      // Step 1: Insert new user
      const { data: newUser, error: insertError } = await supabase
        .from('test_username')
        .insert([{ username, password }])
        .select()
        .single()

      if (insertError) {
        if (insertError.message.includes('duplicate')) {
          setError('Username already taken')
        } else {
          setError('Signup failed: ' + insertError.message)
        }
        setLoading(false)
        return
      }

      // Step 2: Create a trainer for this user
      const { error: trainerError } = await supabase
        .from('trainers')
        .insert([{
          user_id: newUser.id,
          name: username,
          total_points: 0
        }])

      if (trainerError) {
        console.error('Failed to create trainer:', trainerError)
        // Continue anyway - user account was created
      }

      // Success!
      onSuccess(username)
    } catch (err: any) {
      setError('Signup error: ' + err.message)
      setLoading(false)
    }
  }

  return (
    <div className="app-container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '100vh' }}>
      <div style={{ width: 400, padding: 24, border: '1px solid #ddd', borderRadius: 8, background: '#fff' }}>
        <h2 style={{ marginTop: 0 }}>Create Account</h2>
        
        {error && (
          <div style={{ padding: 10, marginBottom: 16, background: '#fee', border: '1px solid #fcc', borderRadius: 6, color: '#c00' }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <label style={{ display: 'block', fontSize: 12, color: '#374151', marginBottom: 4 }}>Username</label>
          <input
            type="text"
            required
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            style={{ width: '100%', padding: 10, borderRadius: 6, border: '1px solid #d1d5db', marginBottom: 12 }}
          />

          <label style={{ display: 'block', fontSize: 12, color: '#374151', marginBottom: 4 }}>Password</label>
          <input
            type="password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            style={{ width: '100%', padding: 10, borderRadius: 6, border: '1px solid #d1d5db', marginBottom: 12 }}
          />

          <label style={{ display: 'block', fontSize: 12, color: '#374151', marginBottom: 4 }}>Confirm Password</label>
          <input
            type="password"
            required
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            style={{ width: '100%', padding: 10, borderRadius: 6, border: '1px solid #d1d5db', marginBottom: 16 }}
          />

          <div style={{ display: 'flex', gap: 8 }}>
            <button
              type="submit"
              disabled={loading}
              style={{ flex: 1, padding: 10, border: 'none', borderRadius: 6, background: '#10b981', color: 'white', cursor: 'pointer' }}
            >
              {loading ? 'Creating...' : 'Sign Up'}
            </button>
            <button
              type="button"
              onClick={onBack}
              style={{ flex: 1, padding: 10, border: 'none', borderRadius: 6, background: '#9ca3af', color: 'white', cursor: 'pointer' }}
            >
              Back
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
