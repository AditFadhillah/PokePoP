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

  // Post-signup Survey Extract URL
  const SURVEY_URL = 'https://www.survey-xact.dk/LinkCollector?key=6TW449XRSK9P'

  // After signup we show the survey before letting the user continue
  const [showSurvey, setShowSurvey] = useState(false)
  const [surveyCompleted, setSurveyCompleted] = useState(false)
  const [signedUpUsername, setSignedUpUsername] = useState<string | null>(null)

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
          test_user_id: newUser.id,  // Link to test_username table
          name: username,
          total_points: 0,
          achievement_points: 0
        }])

      if (trainerError) {
        console.error('Failed to create trainer:', trainerError)
        // Continue anyway - user account was created
      }

      // Signup succeeded. Now show survey before continuing into the app.
      setSignedUpUsername(username)
      setShowSurvey(true)
      setLoading(false)
      return
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

        {!showSurvey && (
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
        )}

        {showSurvey && signedUpUsername && (
          <div style={{ marginTop: 16 }}>
            <h3 style={{ margin: '8px 0' }}>One more step</h3>
            <p style={{ fontSize: 13, color: '#374151', marginTop: 0 }}>
              Please complete this survey to finish setting up your account.
            </p>
            <div style={{ width: '100%', height: 400, border: '1px solid #e5e7eb', borderRadius: 6, overflow: 'hidden', marginBottom: 8 }}>
              <iframe
                src={SURVEY_URL}
                title="Post-signup Survey"
                style={{ width: '100%', height: '100%', border: 0 }}
              />
            </div>
            <label style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 13, color: '#111827', marginBottom: 12 }}>
              <input
                type="checkbox"
                checked={surveyCompleted}
                onChange={(e) => setSurveyCompleted(e.target.checked)}
              />
              I have completed the survey.
            </label>
            <button
              type="button"
              disabled={!surveyCompleted}
              onClick={() => onSuccess(signedUpUsername)}
              style={{ width: '100%', padding: 10, border: 'none', borderRadius: 6, background: surveyCompleted ? '#10b981' : '#d1d5db', color: surveyCompleted ? 'white' : '#6b7280', cursor: surveyCompleted ? 'pointer' : 'not-allowed' }}
            >
              Continue
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
