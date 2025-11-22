import React from 'react'

type Props = {
  open: boolean
  onClose: () => void
  authMessage: string | null
  authBusy: boolean
  loginUsername: string
  setLoginUsername: (v: string) => void
  loginPassword: string
  setLoginPassword: (v: string) => void
  onSubmit: (e: React.FormEvent<HTMLFormElement>) => void
  onSignupClick: (e: React.MouseEvent<HTMLButtonElement>) => void
}

export default function LoginModal({
  open, onClose, authMessage, authBusy,
  loginUsername, setLoginUsername,
  loginPassword, setLoginPassword,
  onSubmit, onSignupClick
}: Props) {
  if (!open) return null

  return (
    <div
      role='dialog'
      aria-modal='true'
      style={{
        position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        zIndex: 1000
      }}
      onClick={(e) => { if (e.target === e.currentTarget) onClose() }}
    >
      <form
        onSubmit={onSubmit}
        className='modal-content'
        style={{
          width: 380,
          background: '#fff',
          borderRadius: 8,
          boxShadow: '0 10px 30px rgba(0,0,0,0.25)',
          overflow: 'hidden',
        }}
      >
        <div style={{ position: 'relative', padding: 16, borderBottom: '1px solid #e5e7eb' }}>
          <strong>Login</strong>
          <button
            type='button'
            onClick={onClose}
            aria-label='Close'
            style={{ position: 'absolute', right: 8, top: 8, border: 'none', background: 'transparent', fontSize: 22, lineHeight: 1, cursor: 'pointer' }}
          >
            &times;
          </button>
        </div>

        <div style={{ padding: 16 }}>
          {authMessage && (
            <div style={{ marginBottom: 10, padding: 8, background: '#fff8e1', border: '1px solid #ffe0b2', borderRadius: 6, color: '#7c4d00' }}>
              {authMessage}
            </div>
          )}

          <label htmlFor='username' style={{ display: 'block', fontSize: 12, color: '#374151' }}>Username</label>
          <input
            id='username'
            type='text'
            required
            placeholder='your_username'
            value={loginUsername}
            onChange={(e) => setLoginUsername(e.target.value)}
            style={{ width: '100%', padding: 10, borderRadius: 6, border: '1px solid #d1d5db', marginBottom: 12 }}
          />

          <label htmlFor='password' style={{ display: 'block', fontSize: 12, color: '#374151' }}>Password</label>
          <input
            id='password'
            type='password'
            required
            placeholder='password'
            value={loginPassword}
            onChange={(e) => setLoginPassword(e.target.value)}
            style={{ width: '100%', padding: 10, borderRadius: 6, border: '1px solid #d1d5db', marginBottom: 16 }}
          />

          <div style={{ display: 'flex', gap: 8 }}>
            <button
              type='submit'
              disabled={authBusy}
              style={{ flex: 1, padding: 10, border: 'none', borderRadius: 6, background: '#2563eb', color: 'white', cursor: 'pointer' }}
            >
              {authBusy ? 'Working...' : 'Login'}
            </button>
            <button
              type='button'
              onClick={onSignupClick}
              disabled={authBusy}
              style={{ flex: 1, padding: 10, border: 'none', borderRadius: 6, background: '#10b981', color: 'white', cursor: 'pointer' }}
            >
              Sign Up
            </button>
          </div>
        </div>

        <div style={{ background: '#f9fafb', padding: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <button type='button' onClick={onClose} style={{ padding: '8px 12px', border: 'none', borderRadius: 6, background: '#9ca3af', color: '#fff', cursor: 'pointer' }}>
            Cancel
          </button>
        </div>
      </form>
    </div>
  )
}
