import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

interface TeamData {
  team: string
  total_points: number
  member_count: number
  avg_points: number
}

export default function TeamLeaderboardPanel() {
  const [teams, setTeams] = useState<TeamData[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadTeamLeaderboard()
  }, [])

  async function loadTeamLeaderboard() {
    try {
      setLoading(true)
      const { data, error } = await supabase
        .from('team_leaderboard')
        .select('*')
        .order('total_points', { ascending: false })
      
      if (error) {
        console.error('Error loading team leaderboard:', error)
      } else {
        setTeams(data || [])
      }
    } catch (error) {
      console.error('Error:', error)
    } finally {
      setLoading(false)
    }
  }

  const getTeamColor = (team: string) => {
    switch (team) {
      case 'red': return '#dc2626'
      case 'blue': return '#2563eb'
      case 'yellow': return '#eddd00ff'
      default: return '#68d391'
    }
  }

  const getTeamEmoji = (index: number) => {
    switch (index) {
      case 0: return '🥇'
      case 1: return '🥈'
      case 2: return '🥉'
      default: return '🏅'
    }
  }

  if (loading) {
    return (
      <div className="leaderboard-section">
        <h3>🏆 Team Leaderboard</h3>
        <div style={{ color: '#9ca3af', textAlign: 'center', padding: '1rem' }}>
          Loading teams...
        </div>
      </div>
    )
  }

  // Calculate max points for progress bar scaling
  const maxPoints = teams.length > 0 ? Math.max(...teams.map(t => t.total_points)) : 0

  return (
    <div className="leaderboard-section">
      {teams.length > 0 ? (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          {teams.map((team, index) => {
            const percentage = maxPoints > 0 ? (team.total_points / maxPoints) * 100 : 0
            
            return (
              <div 
                key={team.team}
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '8px'
                }}
              >
                {/* Team Header */}
                <div style={{ 
                  display: 'flex', 
                  alignItems: 'center', 
                  justifyContent: 'space-between',
                  paddingLeft: '15px',
                  paddingRight: '15px'
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <span style={{ fontSize: '1.5em' }}>{getTeamEmoji(index)}</span>
                    <span 
                      style={{ 
                        color: getTeamColor(team.team),
                        textTransform: 'capitalize',
                        fontWeight: 'bold',
                        fontSize: '1.1em'
                      }}
                    >
                      Team {team.team}
                    </span>
                  </div>
                  <div style={{ display: 'flex', gap: '15px', fontSize: '0.85em' }}>
                    <span style={{ color: '#fbbf24' }}>⭐ {team.total_points}</span>
                    <span style={{ color: '#9ca3af' }}>👥 {team.member_count}</span>
                    {/* <span style={{ color: '#68d391' }}>📊 {Math.round(team.avg_points)}/trainer</span> */}
                  </div>
                </div>

                {/* Progress Bar */}
                <div style={{
                  width: `calc(${percentage}% - 30px)`,
                  height: '8px',
                  backgroundColor: getTeamColor(team.team),
                  borderRadius: '4px',
                  border: `1px solid ${getTeamColor(team.team)}`,
                  transition: 'width 0.5s ease',
                  marginLeft: '15px',
                  marginRight: '15px'
                }}>
                </div>
              </div>
            )
          })}
        </div>
      ) : (
        <div style={{ color: '#9ca3af', textAlign: 'center', padding: '1rem' }}>
          No teams found. Teams will appear once trainers join!
        </div>
      )}
    </div>
  )
}
