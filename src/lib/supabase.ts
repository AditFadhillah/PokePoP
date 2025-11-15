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
  }
}

export const updateDB = () => {
  console.log('Database update function called')
} // REMOVE WHEN DONE WITH DB (MADE BY ADIT)