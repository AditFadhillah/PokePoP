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
            <h3>Common Functions</h3>
            <div className="example-item">
              <h4>Built-in Functions</h4>
              <div className="code-example">
                len(obj) # length of list/string/dict<br/>
                range(n) # 0 to n-1<br/>
                range(start, end) # start to end-1<br/>
                zip(list1, list2) # pair elements<br/>
                dict(zip(keys, values)) # create dict<br/>
                max(list) # find maximum<br/>
                sum(list) # sum all elements<br/>
                bool(value) # convert to True/False
              </div>
            </div>
          </section>

          <section>
            <h3>Loop Patterns</h3>
            <div className="example-item">
              <h4>Basic Loops</h4>
              <div className="code-example">
                # Loop through list<br/>
                for item in list:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;# process item<br/><br/>
                # Loop with range<br/>
                for i in range(5):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;# runs 0 to 4<br/><br/>
                # Loop with range(start, end)<br/>
                for i in range(1, n+1):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;# runs from 1 to n
              </div>
            </div>
            <div className="example-item">
              <h4>Advanced Loops</h4>
              <div className="code-example">
                # Loop through dictionary<br/>
                for key, value in dict.items():<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;print(key, value)<br/><br/>
                # Nested loop (2D patterns)<br/>
                for i in range(n):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;for j in range(m):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# access matrix[i][j]<br/><br/>
                # Count with condition<br/>
                count = 0<br/>
                for item in list:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;if condition:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;count += 1
              </div>
            </div>
          </section>

          <section>
            <h3>String Operations</h3>
            <div className="example-item">
              <h4>String Methods</h4>
              <div className="code-example">
                text.lower() # convert to lowercase<br/>
                text.upper() # convert to uppercase<br/>
                char in text # check if char exists<br/>
                len(text) # get string length<br/>
                text.index('x') # find position of 'x'
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
            <h3>Tuple Operations</h3>
            <div className="example-item">
              <h4>Tuple Basics</h4>
              <div className="code-example">
                # Create tuple<br/>
                t = ('a', 'b', 'c')<br/><br/>
                # Access elements<br/>
                t[0] # first element<br/>
                t[1] # second element<br/><br/>
                # Unpack tuple<br/>
                x, y, z = t<br/><br/>
                # Tuple methods<br/>
                len(t) # length<br/>
                t.index('b') # find index of 'b'<br/><br/>
                # List comprehension from tuple<br/>
                lowercase = [s.lower() for s in t]
              </div>
            </div>
          </section>

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
        </div>
      </div>
    </div>
  )
}

export default ReferencesModal
