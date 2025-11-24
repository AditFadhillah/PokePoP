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
            <div className="example-item">
              <h4>Character Classes</h4>
              <div className="code-example">
                \d # digit (0-9)<br/>
                \w # word character (a-z, A-Z, 0-9, _)<br/>
                \s # whitespace<br/>
                [abc] # character class (a, b, or c)
              </div>
            </div>
            <div className="example-item">
              <h4>Quantifiers & Anchors</h4>
              <div className="code-example">
                + # one or more<br/>
                * # zero or more<br/>
                {"{"} n,m {"}"} # between n and m occurrences<br/>
                ^ # start of string<br/>
                $ # end of string
              </div>
            </div>
          </section>

          <section>
            <h3>Dictionary Methods</h3>
            <div className="example-item">
              <h4>Accessing Data</h4>
              <div className="code-example">
                dict.keys() # get all keys<br/>
                dict.values() # get all values<br/>
                dict.items() # get key-value pairs<br/>
                dict.get(key, default) # safe access
              </div>
            </div>
            <div className="example-item">
              <h4>Modifying Dictionaries</h4>
              <div className="code-example">
                dict.update(other_dict) # merge dictionaries<br/>
                key in dict # check if key exists<br/>
                dict[key] = value # set value<br/>
                del dict[key] # remove key
              </div>
            </div>
          </section>

          <section>
            <h3>Loop Patterns</h3>
            <div className="example-item">
              <h4>Basic Loops</h4>
              <div className="code-example">
                # Simple loop<br/>
                for item in list:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;# process item<br/><br/>
                # Loop with index<br/>
                for i in range(len(list)):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;# use list[i]
              </div>
            </div>
            <div className="example-item">
              <h4>Advanced Loops</h4>
              <div className="code-example">
                # Loop through dictionary<br/>
                for key, value in dict.items():<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;# process key and value<br/><br/>
                # Nested loop<br/>
                for i in range(n):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;for j in range(m):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# process i, j
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
  )
}

export default ReferencesModal
