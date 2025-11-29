import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

interface MilestonesModalProps {
  show: boolean
  onClose: () => void
  userId: string | null
}

interface Achievement {
  achievement_id: string
  achievement_key: string
  title: string
  description: string
  category: string
  icon: string
  unlocked_at: string
  points: number
}

export default function MilestonesModal({ show, onClose, userId }: MilestonesModalProps) {
  const [achievements, setAchievements] = useState<Achievement[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (show && userId) {
      loadAchievements()
    }
  }, [show, userId])

  async function loadAchievements() {
    try {
      setLoading(true)
      console.log('🔍 MilestonesModal: Loading achievements for userId:', userId)
      
      const { data, error } = await supabase
        .rpc('get_user_achievements', { p_user_id: userId })
      
      if (error) {
        console.error('❌ MilestonesModal: Error loading achievements:', error)
        console.error('   - userId passed:', userId)
        console.error('   - error details:', error.message)
        return
      }
      
      if (data) {
        console.log('✅ MilestonesModal: Loaded', data.length, 'achievements')
        console.log('   - Achievements:', data)
        setAchievements(data)
      } else {
        console.log('⚠️ MilestonesModal: No achievements data returned')
      }
    } catch (error) {
      console.error('❌ MilestonesModal: Exception:', error)
    } finally {
      setLoading(false)
    }
  }

  if (!show) return null

  const getCategoryColor = (category: string) => {
    switch (category) {
      case 'first_capture': return '#10b981' // green
      case 'login_streak': return '#3b82f6' // blue
      case 'total_captures': return '#8b5cf6' // purple
      case 'region_complete': return '#f59e0b' // amber
      case 'duration': return '#ec4899' // pink
      default: return '#6b7280' // gray
    }
  }

  const getCategoryName = (category: string) => {
    switch (category) {
      case 'first_capture': return 'First Steps'
      case 'login_streak': return 'Dedication'
      case 'total_captures': return 'Collection'
      case 'region_complete': return 'Mastery'
      case 'duration': return 'Commitment'
      default: return 'Achievement'
    }
  }

  return (
    <div 
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        display: 'flex',
        justifyContent: 'flex-end',
        alignItems: 'center',
        zIndex: 1000,
        padding: '20px'
      }}
      onClick={onClose}
    >
      <div
        style={{
          width: '400px',
          height: '90vh',
          backgroundColor: 'rgba(0, 0, 0, 0.95)',
          color: '#fff',
          padding: '20px',
          overflowY: 'auto',
          boxShadow: '-4px 0 20px rgba(0, 0, 0, 0.5)',
          borderLeft: '3px solid #fbbf24', // yellow border
          borderRadius: '8px',
          marginRight: '20px'
        }}
        onClick={(e) => e.stopPropagation()}
      >
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        marginBottom: '20px',
        borderBottom: '2px solid #fbbf24',
        paddingBottom: '10px'
      }}>
        <h2 style={{ 
          margin: 0, 
          fontSize: '24px',
          color: '#fff', // white
          display: 'flex',
          alignItems: 'center',
          gap: '10px'
        }}>
          Milestones
        </h2>
        <button
          onClick={onClose}
          style={{
            background: 'none',
            border: 'none',
            color: '#fbbf24', // yellow
            fontSize: '24px',
            fontWeight: 'bold',
            cursor: 'pointer',
            padding: 0,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          ×
        </button>
      </div>

      {loading ? (
        <div style={{ 
          textAlign: 'center', 
          padding: '40px 0',
          color: '#fbbf24'
        }}>
          Loading milestones...
        </div>
      ) : achievements.length === 0 ? (
        <div style={{ 
          textAlign: 'center', 
          padding: '40px 20px',
          color: '#9ca3af'
        }}>
          <div style={{ fontSize: '48px', marginBottom: '20px' }}>🎯</div>
          <p style={{ margin: 0, fontSize: '16px' }}>
            No milestones unlocked yet.
            <br />
            Start playing to earn achievements!
          </p>
        </div>
      ) : (
        <>
          <div style={{ 
            marginBottom: '20px',
            padding: '10px',
            backgroundColor: 'rgba(251, 191, 36, 0.1)',
            borderRadius: '8px',
            border: '1px solid rgba(251, 191, 36, 0.3)'
          }}>
            <div style={{ 
              fontSize: '14px', 
              color: '#fbbf24',
              fontWeight: 'bold'
            }}>
              {achievements.length} Milestone{achievements.length !== 1 ? 's' : ''} Unlocked
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
            {achievements.map((achievement) => (
              <div
                key={achievement.achievement_id}
                style={{
                  padding: '15px',
                  backgroundColor: 'rgba(255, 255, 255, 0.05)',
                  borderRadius: '10px',
                  border: `2px solid ${getCategoryColor(achievement.category)}`,
                  transition: 'all 0.3s ease',
                  cursor: 'default',
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.backgroundColor = 'rgba(255, 255, 255, 0.1)'
                  e.currentTarget.style.transform = 'translateX(-5px)'
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.backgroundColor = 'rgba(255, 255, 255, 0.05)'
                  e.currentTarget.style.transform = 'translateX(0)'
                }}
              >
                <div style={{ display: 'flex', gap: '12px', alignItems: 'flex-start' }}>
                  <div style={{ 
                    fontSize: '32px',
                    lineHeight: '1',
                    flexShrink: 0
                  }}>
                    {achievement.icon}
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ 
                      fontSize: '16px', 
                      fontWeight: 'bold',
                      marginBottom: '4px',
                      color: '#fff'
                    }}>
                      {achievement.title}
                    </div>
                    <div style={{ 
                      fontSize: '13px', 
                      color: '#d1d5db',
                      marginBottom: '8px'
                    }}>
                      {achievement.description}
                    </div>
                    <div style={{ 
                      display: 'flex',
                      gap: '8px',
                      fontSize: '11px',
                      alignItems: 'center',
                      flexWrap: 'wrap'
                    }}>
                      <span style={{
                        padding: '3px 8px',
                        backgroundColor: getCategoryColor(achievement.category),
                        borderRadius: '12px',
                        fontWeight: 'bold',
                        color: '#fff'
                      }}>
                        {getCategoryName(achievement.category)}
                      </span>
                      <span style={{
                        padding: '3px 8px',
                        backgroundColor: '#dfc500ff',
                        borderRadius: '12px',
                        fontWeight: 'bold',
                        color: '#000000ff',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '3px'
                      }}>
                        <span style={{ fontSize: '12px' }}></span>{achievement.points} pts
                      </span>
                      <span style={{ color: '#9ca3af' }}>
                        {new Date(achievement.unlocked_at).toLocaleDateString()}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </>
      )}
      </div>
    </div>
  )
}
