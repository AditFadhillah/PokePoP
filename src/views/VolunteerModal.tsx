interface VolunteerModalProps {
  show: boolean
  onClose: () => void
}

function VolunteerModal({ show, onClose }: VolunteerModalProps) {
  if (!show) return null

  return (
    <div className="references-modal-overlay" onClick={onClose}>
      <div className="references-modal" onClick={(e) => e.stopPropagation()}>
        <div className="references-header">
          <h2>Volunteer</h2>
          <button onClick={onClose} className="close-button">×</button>
        </div>
        <div className="references-content" style={{ textAlign: 'center' }}>
          
          <section>
            <h3>Help Us Improve PyMon!</h3>
            <p style={{ fontSize: '1.1em', lineHeight: '1.6', marginBottom: '1.5rem' }}>
              We are conducting a research study to understand how PyMon helps students learn programming.
              Your participation would be incredibly valuable!
            </p>
            
            <div style={{ margin: '2rem 0' }}>
              <h4 style={{ marginBottom: '1rem' }}>Participate in Our Study</h4>
              <a 
                href="https://forms.office.com/e/nbJGKWcCgf" 
                target="_blank" 
                rel="noopener noreferrer"
                style={{
                  display: 'inline-block',
                  padding: '12px 24px',
                  backgroundColor: '#3b82f6',
                  color: 'white',
                  textDecoration: 'none',
                  borderRadius: '8px',
                  fontWeight: 'bold',
                  fontSize: '1.1em',
                  marginBottom: '1rem',
                  transition: 'background-color 0.2s'
                }}
                onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#2563eb'}
                onMouseOut={(e) => e.currentTarget.style.backgroundColor = '#3b82f6'}
              >
                Open Volunteer Form
              </a>
              
              <div style={{ margin: '2rem 0' }}>
                <p style={{ marginBottom: '1rem', color: '#9ca3af' }}>Or scan this QR code:</p>
                <img 
                  src="/PyMon/QRforms.png" 
                  alt="QR Code for Volunteer Form" 
                  style={{ 
                    maxWidth: '250px', 
                    width: '100%',
                    border: '2px solid #e5e7eb',
                    borderRadius: '8px',
                    padding: '10px',
                    backgroundColor: 'white'
                  }}
                />
              </div>
            </div>

            <div style={{ 
              marginTop: '2rem', 
              padding: '1.5rem', 
              backgroundColor: 'rgba(59, 130, 246, 0.1)', 
              borderRadius: '8px',
              border: '1px solid rgba(59, 130, 246, 0.3)'
            }}>
              <h4 style={{ marginBottom: '0.5rem' }}>Questions or Concerns?</h4>
              <p style={{ marginBottom: '0.5rem' }}>Feel free to reach out to us:</p>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                <div>
                  <span style={{ color: '#6b7280', fontWeight: 'normal', fontSize: '1.1em' }}>Adit: </span>
                  <a 
                    href="mailto:hjg708@alumni.ku.dk" 
                    style={{ 
                      color: '#3b82f6', 
                      textDecoration: 'none',
                      fontWeight: 'bold',
                      fontSize: '1.1em'
                    }}
                  >
                    hjg708@alumni.ku.dk
                  </a>
                </div>
                
                <div>
                  <span style={{ color: '#6b7280', fontWeight: 'normal', fontSize: '1.1em' }}>Qianqian: </span>
                  <a 
                    href="mailto:tgq379@alumni.ku.dk" 
                    style={{ 
                      color: '#3b82f6', 
                      textDecoration: 'none',
                      fontWeight: 'bold',
                      fontSize: '1.1em'
                    }}
                  >
                    tgq379@alumni.ku.dk
                  </a>
                </div>
              </div>
              <p style={{ marginTop: '1rem', fontSize: '0.9em', color: '#6b7280' }}>
                Your participation is completely voluntary and all data will be kept confidential.
              </p>
            </div>
          </section>

        </div>
      </div>
    </div>
  )
}

export default VolunteerModal
