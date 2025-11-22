import { createClient } from '@supabase/supabase-js'

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL!,
  import.meta.env.VITE_SUPABASE_ANON_KEY!,
  { auth: { persistSession: true, autoRefreshToken: true } }
)

// Database types for TypeScript support
export interface Trainer {
  id: string
  user_id: string
  name: string
  total_points: number
  created_at: string
  updated_at: string
}

export interface PokemonInventory {
  id: string
  trainer_id: string
  pokemon_name: string
  level: number
  points: number
  captured_at: string
  capture_time_ms?: number | null  // Time taken to capture in milliseconds
}

export interface UsageSession {
  id: string
  username: string
  meta: any // JSON object for storing session metadata
  started_at: string
  last_beat_at: string
  ended_at: string | null
  active_ms: number
  created_at: string
}

// Helper functions for database operations
export const dbHelpers = {
  // Get trainer by name and user
  async getTrainerByName(name: string) {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return null

    const { data, error } = await supabase
      .from('trainers')
      .select('*')
      .eq('user_id', user.id)
      .eq('name', name)
      .single()

    return { data, error }
  },

  // Get all trainers for current user
  async getUserTrainers() {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      // If no user is authenticated, return all trainers (for development/testing)
      return this.getAllTrainers()
    }

    const { data, error } = await supabase
      .from('trainers')
      .select('*')
      .eq('user_id', user.id)
      .order('total_points', { ascending: false })

    return { data, error }
  },

  // Get all trainers (regardless of user - for development/testing)
  async getAllTrainers() {
    const { data, error } = await supabase
      .from('trainers')
      .select('*')
      .order('total_points', { ascending: false })

    return { data, error }
  },

  // Get leaderboard (all trainers)
  async getLeaderboard(limit = 10) {
    const { data, error } = await supabase
      .from('trainer_leaderboard')
      .select('*')
      .limit(limit)

    return { data, error }
  },

  // Get Pokemon inventory for a trainer
  async getTrainerInventory(trainerId: string) {
    const { data, error } = await supabase
      .from('pokemon_inventory')
      .select('*')
      .eq('trainer_id', trainerId)
      .order('captured_at', { ascending: false })

    return { data, error }
  },

  // Create a new trainer
  async createTrainer(name: string) {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return { data: null, error: 'No user' }

    const { data, error } = await supabase
      .from('trainers')
      .insert([
        {
          user_id: user.id,
          name: name,
          total_points: 0
        }
      ])
      .select()
      .single()

    return { data, error }
  },

  // Usage Session Management
  
  // Create a new usage session
  async createUsageSession(username: string, metadata: any = {}) {
    const { data, error } = await supabase
      .from('usage_sessions')
      .insert([
        {
          username: username,
          meta: metadata,
          started_at: new Date().toISOString(),
          last_beat_at: new Date().toISOString(),
          active_ms: 0
        }
      ])
      .select()
      .single()

    return { data, error }
  },

  // Update session heartbeat (call periodically while user is active)
  async updateSessionHeartbeat(sessionId: string, activeMs: number) {
    const { data, error } = await supabase
      .from('usage_sessions')
      .update({
        last_beat_at: new Date().toISOString(),
        active_ms: activeMs
      })
      .eq('id', sessionId)
      .select()
      .single()

    return { data, error }
  },

  // End a usage session
  async endUsageSession(sessionId: string, activeMs: number) {
    const { data, error } = await supabase
      .from('usage_sessions')
      .update({
        ended_at: new Date().toISOString(),
        last_beat_at: new Date().toISOString(),
        active_ms: activeMs
      })
      .eq('id', sessionId)
      .select()
      .single()

    return { data, error }
  },

  // Get all sessions for a user
  async getUserSessions(username: string) {
    const { data, error } = await supabase
      .from('usage_sessions')
      .select('*')
      .eq('username', username)
      .order('started_at', { ascending: false })

    return { data, error }
  },

  // Get active sessions (not ended yet)
  async getActiveSessions() {
    const { data, error } = await supabase
      .from('usage_sessions')
      .select('*')
      .is('ended_at', null)
      .order('started_at', { ascending: false })

    return { data, error }
  },

  // Get session statistics for a user
  async getUserSessionStats(username: string) {
    const { data, error } = await supabase
      .from('usage_sessions')
      .select('active_ms, started_at, ended_at')
      .eq('username', username)

    if (error) return { data: null, error }

    // Calculate statistics
    const totalSessions = data.length
    const totalActiveMs = data.reduce((sum, session) => sum + (session.active_ms || 0), 0)
    const averageSessionMs = totalSessions > 0 ? totalActiveMs / totalSessions : 0

    return {
      data: {
        totalSessions,
        totalActiveMs,
        averageSessionMs,
        totalActiveMinutes: Math.floor(totalActiveMs / 60000),
        averageSessionMinutes: Math.floor(averageSessionMs / 60000)
      },
      error: null
    }
  }
}

export const updateDB = () => {
  console.log('Database update function called')
} // REMOVE WHEN DONE WITH DB (MADE BY ADIT)