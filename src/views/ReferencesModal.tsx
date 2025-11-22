interface ReferencesModalProps {
  show: boolean
  onClose: () => void
}

function ReferencesModal({ show, onClose }: ReferencesModalProps) {
  if (!show) return null

  return (
    <div className="references-modal-overlay" onClick={onClose}>
      <div className="references-modal" onClick={(e) => e.stopPropagation()}>
        <div className="references-header">
          <h2>Python Quick Reference</h2>
          <button onClick={onClose} className="close-button">×</button>
        </div>
        <div className="references-content">
          <section>
            <h3>Common Regex Patterns</h3>
            <ul>
              <li>\d = digit (0-9)</li>
              <li>\w = word character (a-z, A-Z, 0-9, _)</li>
              <li>\s = whitespace</li>
              <li>+ = one or more</li>
              <li>* = zero or more</li>
              <li>{"{"} n,m {"}"} = between n and m occurrences</li>
              <li>^ = start of string</li>
              <li>$ = end of string</li>
              <li>[abc] = character class (a, b, or c)</li>
            </ul>
          </section>

          <section>
            <h3>Dictionary Methods</h3>
            <ul>
              <li>dict.keys() = get all keys</li>
              <li>dict.values() = get all values</li>
              <li>dict.items() = get key-value pairs</li>
              <li>dict.get(key, default) = safe access</li>
              <li>dict.update(other_dict) = merge dictionaries</li>
              <li>key in dict = check if key exists</li>
            </ul>
          </section>

          <section>
            <h3>Loop Patterns</h3>
            <div className="code-example">
              <strong># Simple loop</strong><br/>
              for item in list:<br/>
              &nbsp;&nbsp;&nbsp;&nbsp;# process item<br/><br/>

              <strong># Loop with index</strong><br/>
              for i in range(len(list)):<br/>
              &nbsp;&nbsp;&nbsp;&nbsp;# use list[i]<br/><br/>

              <strong># Loop through dictionary</strong><br/>
              for key, value in dict.items():<br/>
              &nbsp;&nbsp;&nbsp;&nbsp;# process key and value<br/><br/>

              <strong># Nested loop</strong><br/>
              for i in range(n):<br/>
              &nbsp;&nbsp;&nbsp;&nbsp;for j in range(m):<br/>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# process i, j
            </div>
          </section>
        </div>
      </div>
    </div>
  )
}

export default ReferencesModal
