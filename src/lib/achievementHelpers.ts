import { supabase } from './supabase'

interface UserStats {
  user_id: string
  trainer_id: string
  total_captures: number
  forest_captures: number
  beach_captures: number
  volcano_captures: number
  swamp_captures: number
  current_login_streak: number
  longest_login_streak: number
  last_login_date: string | null
  total_duration_minutes: number
  longest_session_minutes: number
}

// Initialize user stats if they don't exist
export async function initializeUserStats(userId: string, trainerId: string) {
  try {
    const { data: existing } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle()

    if (!existing) {
      const { error } = await supabase
        .from('user_stats')
        .insert({
          user_id: userId,
          trainer_id: trainerId,
          total_captures: 0,
          forest_captures: 0,
          beach_captures: 0,
          volcano_captures: 0,
          swamp_captures: 0,
          current_login_streak: 1,
          longest_login_streak: 1,
          last_login_date: new Date().toISOString().split('T')[0],
          total_duration_minutes: 0,
          longest_session_minutes: 0
        })

      if (error) {
        console.error('Error initializing user stats:', error)
      }
    }
  } catch (error) {
    console.error('Error checking/initializing user stats:', error)
  }
}

// Update capture stats when a Pokemon is captured
export async function updateCaptureStats(userId: string, trainerId: string, region: string) {
  try {
    // Get current stats
    const { data: stats } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', userId)
      .single()

    if (!stats) {
      await initializeUserStats(userId, trainerId)
    }

    // Increment total captures
    const updates: any = {
      total_captures: (stats?.total_captures || 0) + 1
    }

    // Increment region-specific captures
    const regionColumn = `${region.toLowerCase()}_captures`
    if (['forest', 'beach', 'volcano', 'swamp'].includes(region.toLowerCase())) {
      updates[regionColumn] = (stats?.[regionColumn] || 0) + 1
    }

    // Update stats
    const { error } = await supabase
      .from('user_stats')
      .update(updates)
      .eq('user_id', userId)

    if (error) {
      console.error('Error updating capture stats:', error)
    } else {
      // Check for new achievements
      await checkAndAwardAchievements(userId, trainerId)
    }
  } catch (error) {
    console.error('Error updating capture stats:', error)
  }
}

// Update login streak
export async function updateLoginStreak(userId: string, trainerId: string) {
  try {
    const { data: stats } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', userId)
      .single()

    if (!stats) {
      await initializeUserStats(userId, trainerId)
      return
    }

    const today = new Date().toISOString().split('T')[0]
    const lastLogin = stats.last_login_date

    if (!lastLogin || lastLogin === today) {
      // Already logged in today, no update needed
      return
    }

    const yesterday = new Date()
    yesterday.setDate(yesterday.getDate() - 1)
    const yesterdayStr = yesterday.toISOString().split('T')[0]

    let newStreak = 1
    if (lastLogin === yesterdayStr) {
      // Consecutive day login
      newStreak = (stats.current_login_streak || 0) + 1
    }

    const longestStreak = Math.max(newStreak, stats.longest_login_streak || 0)

    const { error } = await supabase
      .from('user_stats')
      .update({
        current_login_streak: newStreak,
        longest_login_streak: longestStreak,
        last_login_date: today
      })
      .eq('user_id', userId)

    if (error) {
      console.error('Error updating login streak:', error)
    } else {
      // Check for new achievements
      await checkAndAwardAchievements(userId, trainerId)
    }
  } catch (error) {
    console.error('Error updating login streak:', error)
  }
}

// Update session duration
export async function updateSessionDuration(userId: string, durationMinutes: number) {
  try {
    const { data: stats } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', userId)
      .single()

    if (!stats) return

    const newTotalDuration = (stats.total_duration_minutes || 0) + durationMinutes
    const longestSession = Math.max(durationMinutes, stats.longest_session_minutes || 0)

    const { error } = await supabase
      .from('user_stats')
      .update({
        total_duration_minutes: newTotalDuration,
        longest_session_minutes: longestSession
      })
      .eq('user_id', userId)

    if (error) {
      console.error('Error updating session duration:', error)
    } else {
      // Check for new achievements (duration-based)
      const { data } = await supabase
        .from('user_stats')
        .select('trainer_id')
        .eq('user_id', userId)
        .single()
      
      if (data?.trainer_id) {
        await checkAndAwardAchievements(userId, data.trainer_id)
      }
    }
  } catch (error) {
    console.error('Error updating session duration:', error)
  }
}

// Check and award achievements
export async function checkAndAwardAchievements(userId: string, trainerId: string) {
  try {
    const { data, error } = await supabase
      .rpc('check_and_award_achievements', {
        p_user_id: userId,
        p_trainer_id: trainerId
      })

    if (error) {
      console.error('Error checking achievements:', error)
      return []
    }

    // Return newly unlocked achievements
    return data || []
  } catch (error) {
    console.error('Error checking achievements:', error)
    return []
  }
}

// Get user's current stats
export async function getUserStats(userId: string): Promise<UserStats | null> {
  try {
    const { data, error } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', userId)
      .single()

    if (error) {
      console.error('Error fetching user stats:', error)
      return null
    }

    return data
  } catch (error) {
    console.error('Error fetching user stats:', error)
    return null
  }
}
