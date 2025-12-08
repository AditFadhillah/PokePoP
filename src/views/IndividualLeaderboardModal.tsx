import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

interface Trainer {
  id: string
  name: string
  total_points: number
  user_id?: string
}

interface IndividualLeaderboardModalProps {
  show: boolean
  onClose: () => void
  currentUserId: string | null
}

export default function IndividualLeaderboardModal({ show, onClose, currentUserId }: IndividualLeaderboardModalProps) {
  const [leaderboard, setLeaderboard] = useState<Trainer[]>([])
  const [loading, setLoading] = useState(true)
  const [userPosition, setUserPosition] = useState<{rank: number, trainer: Trainer} | null>(null)

  useEffect(() => {
    if (show) {
      loadLeaderboard()
    }
  }, [show, currentUserId])

  async function loadLeaderboard() {
    try {
      setLoading(true)
      
      // Get all trainers
      const { data, error } = await supabase
        .from('trainer_leaderboard')
        .select('*')
        .order('total_points', { ascending: false })
      
      if (error) {
        console.error('Error loading leaderboard:', error)
      } else {
        setLeaderboard(data || [])
        
        // Find current user's position if logged in
        if (currentUserId) {
          const { data: allTrainers, error: allError } = await supabase
            .from('trainer_leaderboard')
            .select('*')
            .order('total_points', { ascending: false })
          
          if (!allError && allTrainers) {
            const userTrainerIndex = allTrainers.findIndex(t => t.user_id === currentUserId)
            if (userTrainerIndex !== -1) {
              setUserPosition({
                rank: userTrainerIndex + 1,
                trainer: allTrainers[userTrainerIndex]
              })
            }
          }
        }
      }
    } catch (error) {
      console.error('Error:', error)
    } finally {
      setLoading(false)
    }
  }

  if (!show) return null

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
          width: '800px', // CHANGE THIS VALUE to adjust modal width (e.g., 800px for 2 columns, 1000px for wider)
          height: '90vh',
          backgroundColor: 'rgba(0, 0, 0, 0.95)',
          color: '#fff',
          padding: '20px',
          overflowY: 'auto',
          boxShadow: '-4px 0 20px rgba(0, 0, 0, 0.5)',
          borderLeft: '3px solid #9f7aea',
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
          borderBottom: '2px solid #9f7aea',
          paddingBottom: '10px'
        }}>
          <h2 style={{ 
            margin: 0, 
            fontSize: '24px',
            color: '#fff',
            display: 'flex',
            alignItems: 'center',
            gap: '10px'
          }}>
            Leaderboard
          </h2>
          <button
            onClick={onClose}
            style={{
              background: 'none',
              border: 'none',
              color: '#9f7aea',
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
        
        {/* User Position Header */}
        {userPosition && (
          <div style={{
            background: 'linear-gradient(135deg, rgba(159, 122, 234, 0.2) 0%, rgba(139, 92, 246, 0.1) 100%)',
            padding: '20px',
            borderRadius: '12px',
            marginBottom: '20px',
            border: '2px solid #9f7aea',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '15px'
          }}>
            <span style={{ fontSize: '1.8em', fontWeight: 'bold', color: '#fbbf24' }}>
              #{userPosition.rank}
            </span>
            <span style={{ fontSize: '1.2em', color: '#fff' }}>
              {userPosition.trainer.name}
            </span>
            <span style={{ fontSize: '1.1em', color: '#68d391' }}>
              ⭐ {userPosition.trainer.total_points}
            </span>
          </div>
        )}
        
        {loading ? (
          <div style={{ textAlign: 'center', padding: '2rem', color: '#9ca3af' }}>
            Loading trainers...
          </div>
        ) : leaderboard.length > 0 ? (
          <div style={{ 
            display: 'grid', 
            gridTemplateColumns: 'repeat(2, 1fr)', // 2 columns layout - change to 'repeat(3, 1fr)' for 3 columns
            gap: '10px' 
          }}>
            {leaderboard.map((trainer, index) => (
              <div key={trainer.id} style={{
                background: 'rgba(255, 255, 255, 0.05)',
                padding: '15px 20px',
                borderRadius: '8px',
                border: '1px solid #4a5568',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                  <span style={{
                    fontSize: '1.2em',
                    fontWeight: 'bold',
                    color: index === 0 ? '#fbbf24' : index === 1 ? '#9ca3af' : index === 2 ? '#cd7f32' : '#68d391',
                    minWidth: '40px'
                  }}>
                    {index === 0 ? '🥇' : index === 1 ? '🥈' : index === 2 ? '🥉' : `#${index + 1}`}
                  </span>
                  <span style={{ fontSize: '1.1em', color: '#fff' }}>
                    {trainer.name}
                  </span>
                </div>
                <span style={{ fontSize: '1em', color: '#fbbf24', fontWeight: 'bold' }}>
                  ⭐ {trainer.total_points}
                </span>
              </div>
            ))}
          </div>
        ) : (
          <div style={{ textAlign: 'center', padding: '2rem', color: '#9ca3af' }}>
            No trainers found. Start capturing Pokemon!
          </div>
        )}
      </div>
    </div>
  )
}
