import { useEffect, useRef, useState } from 'react'
import { dbHelpers } from './supabase'

/**
 * Custom hook to track and manage user usage sessions
 * Automatically starts a session when component mounts and ends it on unmount
 * Sends periodic heartbeats to track active time
 */
export function useUsageSession(username: string | null, metadata: any = {}) {
  const [sessionId, setSessionId] = useState<string | null>(null)
  const [sessionActive, setSessionActive] = useState(false)
  const activeTimeRef = useRef(0)
  const lastUpdateRef = useRef(Date.now())
  const heartbeatIntervalRef = useRef<NodeJS.Timeout | null>(null)
  const sessionIdRef = useRef<string | null>(null)

  // Helper function to get device info
  const getDeviceInfo = () => {
    return {
      ua: navigator.userAgent,
      platform: navigator.platform,
      language: navigator.language,
      screenResolution: `${window.screen.width}x${window.screen.height}`,
      viewport: `${window.innerWidth}x${window.innerHeight}`,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      ...metadata
    }
  }

  // Start session when username is available
  useEffect(() => {
    if (!username) return

    const startSession = async () => {
      console.log('🟢 Starting usage session for:', username)
      const enrichedMetadata = getDeviceInfo()
      const { data, error } = await dbHelpers.createUsageSession(username, enrichedMetadata)

      if (error) {
        console.error('Failed to create usage session:', error)
        return
      }

      if (data) {
        setSessionId(data.id)
        sessionIdRef.current = data.id
        setSessionActive(true)
        activeTimeRef.current = 0
        lastUpdateRef.current = Date.now()
        console.log('✅ Usage session started:', data.id)
      }
    }

    startSession()

    // Cleanup on unmount
    return () => {
      if (sessionIdRef.current) {
        // Call endSession immediately with the ref value
        const finalActiveTime = activeTimeRef.current + (Date.now() - lastUpdateRef.current)
        dbHelpers.endUsageSession(sessionIdRef.current, finalActiveTime).then(() => {
          console.log('✅ Session ended on unmount')
        })
      }
    }
  }, [username])

  // Track active time and send heartbeats
  useEffect(() => {
    if (!sessionId || !sessionActive) return

    // Update active time every second
    const trackingInterval = setInterval(() => {
      const now = Date.now()
      const elapsed = now - lastUpdateRef.current
      activeTimeRef.current += elapsed
      lastUpdateRef.current = now
    }, 1000)

    // Send heartbeat every 30 seconds
    heartbeatIntervalRef.current = setInterval(async () => {
      if (sessionId) {
        const { error } = await dbHelpers.updateSessionHeartbeat(
          sessionId,
          activeTimeRef.current
        )

        if (error) {
          console.error('Failed to update heartbeat:', error)
        } 
        // else {
        //   console.log('💓 Heartbeat sent - Active time:', Math.floor(activeTimeRef.current / 1000), 's')
        // }
      }
    }, 30000) // 30 seconds

    return () => {
      clearInterval(trackingInterval)
      if (heartbeatIntervalRef.current) {
        clearInterval(heartbeatIntervalRef.current)
      }
    }
  }, [sessionId, sessionActive])

  // Handle page visibility changes (pause when tab is hidden)
  useEffect(() => {
    const handleVisibilityChange = () => {
      if (document.hidden) {
        // Page is hidden - pause tracking
        lastUpdateRef.current = Date.now()
      } else {
        // Page is visible - resume tracking
        lastUpdateRef.current = Date.now()
      }
    }

    document.addEventListener('visibilitychange', handleVisibilityChange)

    return () => {
      document.removeEventListener('visibilitychange', handleVisibilityChange)
    }
  }, [])

  // Handle browser close/refresh
  useEffect(() => {
    const handleBeforeUnload = () => {
      if (sessionIdRef.current) {
        const finalActiveTime = activeTimeRef.current + (Date.now() - lastUpdateRef.current)
        // Use sendBeacon for reliable data send on page unload
        const data = JSON.stringify({
          sessionId: sessionIdRef.current,
          activeMs: finalActiveTime
        })
        navigator.sendBeacon('/api/end-session', data)
        
        // Also try sync request as fallback
        dbHelpers.endUsageSession(sessionIdRef.current, finalActiveTime)
      }
    }

    window.addEventListener('beforeunload', handleBeforeUnload)

    return () => {
      window.removeEventListener('beforeunload', handleBeforeUnload)
    }
  }, [])

  // Function to end the session
  const endSession = async () => {
    if (!sessionId) return

    console.log('🔴 Ending usage session:', sessionId)
    setSessionActive(false)

    // Final heartbeat with total active time
    const { error } = await dbHelpers.endUsageSession(
      sessionId,
      activeTimeRef.current
    )

    if (error) {
      console.error('Failed to end usage session:', error)
    } else {
      console.log('✅ Usage session ended - Total active time:', Math.floor(activeTimeRef.current / 1000), 's')
    }

    setSessionId(null)
  }

  // Get current active time in milliseconds
  const getActiveTime = () => {
    return activeTimeRef.current
  }

  // Get current active time in seconds
  const getActiveTimeSeconds = () => {
    return Math.floor(activeTimeRef.current / 1000)
  }

  // Get current active time in minutes
  const getActiveTimeMinutes = () => {
    return Math.floor(activeTimeRef.current / 60000)
  }

  return {
    sessionId,
    sessionActive,
    getActiveTime,
    getActiveTimeSeconds,
    getActiveTimeMinutes,
    endSession
  }
}
