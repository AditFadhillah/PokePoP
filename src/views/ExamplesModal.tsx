interface ExamplesModalProps {
  show: boolean
  onClose: () => void
}

function ExamplesModal({ show, onClose }: ExamplesModalProps) {
  if (!show) return null

  return (
    <div className="examples-modal-overlay" onClick={onClose}>
      <div className="examples-modal" onClick={(e) => e.stopPropagation()}>
        <div className="examples-header">
          <h2>Python Code Examples</h2>
          <button onClick={onClose} className="close-button">×</button>
        </div>
        <div className="examples-content">
          <section>
            <h3>Loops</h3>
            <div className="example-item">
              <h4>Example 1: Count Vowels</h4>
              <div className="code-example">
                def count_vowels(text):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;vowels = 'aeiouAEIOU'<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;count = 0<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;for char in text:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if char in vowels:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;count += 1<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;return count<br/><br/>
                result = count_vowels('hello world')<br/>
                print(result)  # Output: 3
              </div>
            </div>
            <div className="example-item">
              <h4>Example 2: Sum List</h4>
              <div className="code-example">
                def sum_list(numbers):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;total = 0<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;for num in numbers:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;total += num<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;return total<br/><br/>
                result = sum_list([1, 2, 3, 4, 5])<br/>
                print(result)  # Output: 15
              </div>
            </div>
          </section>

          <section>
            <h3>Dictionaries</h3>
            <div className="example-item">
              <h4>Example 1: Check Key Exists</h4>
              <div className="code-example">
                pokemon = {'{'}'name': 'Pikachu', 'type': 'Electric', 'level': 25{'}'}<br/><br/>
                # Method 1: Using 'in'<br/>
                print('name' in pokemon)  # Output: True<br/><br/>
                # Method 2: Using .get()<br/>
                print(pokemon.get('name') is not None)  # Output: True
              </div>
            </div>
            <div className="example-item">
              <h4>Example 2: Reverse Dictionary</h4>
              <div className="code-example">
                def reverse_dict(input_dict):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;return {'{'}value: key for key, value in input_dict.items(){'}'}<br/><br/>
                data = {'{'}'a': '1', 'b': '2', 'c': '3'{'}'}<br/>
                result = reverse_dict(data)<br/>
                print(result)  # Output: {'{'}'1': 'a', '2': 'b', '3': 'c'{'}'}
              </div>
            </div>
          </section>

          <section>
            <h3>Nested Loops</h3>
            <div className="example-item">
              <h4>Example 1: Multiplication Table</h4>
              <div className="code-example">
                def print_table(n):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;for i in range(1, n+1):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;for j in range(1, n+1):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print(i * j, end=' ')<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print()  # New line<br/><br/>
                print_table(3)<br/>
                # Output:<br/>
                # 1 2 3<br/>
                # 2 4 6<br/>
                # 3 6 9
              </div>
            </div>
            <div className="example-item">
              <h4>Example 2: Sum 2D List</h4>
              <div className="code-example">
                matrix = [[1,2,3], [4,5,6], [7,8,9]]<br/>
                total = 0<br/><br/>
                for row in matrix:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;for num in row:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;total += num<br/><br/>
                print(total)  # Output: 45
              </div>
            </div>
          </section>

          <section>
            <h3>Regex</h3>
            <div className="example-item">
              <h4>Example 1: Find Email</h4>
              <div className="code-example">
                import re<br/><br/>
                def has_email(text):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;pattern = r'\w+@\w+\.\w+'<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;return re.search(pattern, text) is not None<br/><br/>
                result = has_email('Contact: user@example.com')<br/>
                print(result)  # Output: True
              </div>
            </div>
            <div className="example-item">
              <h4>Example 2: Extract Phone Numbers</h4>
              <div className="code-example">
                import re<br/><br/>
                text = 'Call 123-456-7890 or 098-765-4321'<br/>
                phones = re.findall(r'\d{'{'}3{'}'}-\d{'{'}3{'}'}-\d{'{'}4{'}'}', text)<br/><br/>
                print(phones)<br/>
                # Output: ['123-456-7890', '098-765-4321']
              </div>
            </div>
          </section>

          <section>
            <h3>Tuples</h3>
            <div className="example-item">
              <h4>Example 1: Tuple Unpacking</h4>
              <div className="code-example">
                month_abbrevs = ('Jan', 'Feb', 'Mar')<br/>
                first_month, second_month, third_month = month_abbrevs<br/><br/>
                print(first_month, second_month, third_month)<br/>
                # Output: Jan Feb Mar
              </div>
            </div>
            <div className="example-item">
              <h4>Example 2: Tuple to Lowercase List</h4>
              <div className="code-example">
                month_abbrevs = ('Jan', 'Feb', 'Mar', 'Apr')<br/>
                month_abbrevs_lower = [month.lower() for month in month_abbrevs]<br/><br/>
                print(month_abbrevs_lower)<br/>
                # Output: ['jan', 'feb', 'mar', 'apr']
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
  )
}

export default ExamplesModal
