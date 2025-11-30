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
            <h3>Forest - Loops</h3>
            <div className="example-item">
              <h4>Count Vowels in String</h4>
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
              <h4>Print Dictionary Key-Value Pairs</h4>
              <div className="code-example">
                def print_dict(dictionary):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;for key, value in dictionary.items():<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print(key, value)<br/><br/>
                data = {'{'}'name': 'Pikachu', 'type': 'Electric'{'}'}<br/>
                print_dict(data)<br/>
                # Output:<br/>
                # name Pikachu<br/>
                # type Electric
              </div>
            </div>
            <div className="example-item">
              <h4>Find Even Numbers</h4>
              <div className="code-example">
                evens = []<br/>
                for num in range(21):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;if num % 2 == 0:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;evens.append(num)<br/><br/>
                print(evens)<br/>
                # Output: [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
              </div>
            </div>
          </section>

          <section>
            <h3>Beach - Dictionaries</h3>
            <div className="example-item">
              <h4>Check if Key Exists</h4>
              <div className="code-example">
                pokemon = {'{'}'name': 'Pikachu', 'type': 'Electric'{'}'}<br/><br/>
                # Using 'in' keyword<br/>
                result = 'name' in pokemon<br/>
                print(result)  # Output: True
              </div>
            </div>
            <div className="example-item">
              <h4>Dictionary from Two Lists</h4>
              <div className="code-example">
                keys = ['name', 'age', 'city']<br/>
                values = ['Alice', 25, 'NYC']<br/><br/>
                person = dict(zip(keys, values))<br/>
                print(person)<br/>
                # Output: {'{'}'name': 'Alice', 'age': 25, 'city': 'NYC'{'}'}
              </div>
            </div>
            <div className="example-item">
              <h4>Merge Two Dictionaries</h4>
              <div className="code-example">
                def merge_dicts(dict1, dict2):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;merged = dict1.copy()<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;merged.update(dict2)<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;return merged<br/><br/>
                d1 = {'{'}'a': 1, 'b': 2{'}'}<br/>
                d2 = {'{'}'b': 3, 'c': 4{'}'}<br/>
                result = merge_dicts(d1, d2)<br/>
                print(result)  # Output: {'{'}'a': 1, 'b': 3, 'c': 4'{'}'}
              </div>
            </div>
          </section>

          <section>
            <h3>Nested Loops</h3>
            <div className="example-item">
              <h4>Triangle Pattern</h4>
              <div className="code-example">
                n = 4<br/>
                for i in range(1, n + 1):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;for j in range(i):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print('*', end='')<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;print()<br/><br/>
                # Output:<br/>
                # *<br/>
                # **<br/>
                # ***<br/>
                # ****
              </div>
            </div>
            <div className="example-item">
              <h4>Sum 2D List (Matrix)</h4>
              <div className="code-example">
                matrix = [[1,2,3], [4,5,6], [7,8,9]]<br/>
                total = 0<br/><br/>
                for row in matrix:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;for num in row:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;total += num<br/><br/>
                print(total)  # Output: 45
              </div>
            </div>
            <div className="example-item">
              <h4>Print Coordinates</h4>
              <div className="code-example">
                for x in range(3):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;for y in range(3):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print(x, y, end=' ')<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;print()<br/><br/>
                # Output:<br/>
                # 0 0 0 1 0 2<br/>
                # 1 0 1 1 1 2<br/>
                # 2 0 2 1 2 2
              </div>
            </div>
          </section>

          <section>
            <h3>Volcano - Regex</h3>
            <div className="example-item">
              <h4>Find Word with Regex</h4>
              <div className="code-example">
                import re<br/><br/>
                def has_python(text):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;pattern = r'Python'<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;return bool(re.search(pattern, text))<br/><br/>
                result = has_python('I love Python')<br/>
                print(result)  # Output: True
              </div>
            </div>
            <div className="example-item">
              <h4>Replace with Regex</h4>
              <div className="code-example">
                import re<br/><br/>
                text = 'cat and rat'<br/>
                result = re.sub(r'a', 'o', text)<br/><br/>
                print(result)  # Output: cot ond rot
              </div>
            </div>
            <div className="example-item">
              <h4>Find All Numbers</h4>
              <div className="code-example">
                import re<br/><br/>
                text = 'I have 3 cats and 2 dogs'<br/>
                numbers = re.findall(r'\d+', text)<br/><br/>
                print(numbers)  # Output: ['3', '2']
              </div>
            </div>
          </section>

          <section>
            <h3>Beach - Advanced Dictionaries</h3>
            <div className="example-item">
              <h4>Create Dictionary from Two Lists</h4>
              <div className="code-example">
                keys = ['name', 'age', 'city']<br/>
                values = ['Alice', 25, 'NYC']<br/>
                person = dict(zip(keys, values))<br/><br/>
                print(person)<br/>
                # Output: {'{'}'name': 'Alice', 'age': 25, 'city': 'NYC'{'}'}
              </div>
            </div>
            <div className="example-item">
              <h4>Reverse Dictionary with Comprehension</h4>
              <div className="code-example">
                zodiacs = {'{'}"2020":"rat", "2021":"ox"{'}'}<br/>
                reversed = dict()<br/>
                for key, value in zodiacs.items():<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;reversed[value] = key<br/><br/>
                print(reversed)<br/>
                # Output: {'{'}'rat': '2020', 'ox': '2021'{'}'}
              </div>
            </div>
            <div className="example-item">
              <h4>Count Word Occurrences</h4>
              <div className="code-example">
                words = ['cat', 'dog', 'cat', 'bird', 'dog', 'cat']<br/>
                word_count = {'{'}{'}'}<br/>
                for word in words:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;if word in word_count:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;word_count[word] += 1<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;else:<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;word_count[word] = 1<br/>
                print(word_count)<br/>
                # Output: {'{'}'cat': 3, 'dog': 2, 'bird': 1{'}'}
              </div>
            </div>
          </section>

          <section>
            <h3>Swamp - Mixed Advanced Concepts</h3>
            <div className="example-item">
              <h4>Reverse Dictionary with For Loop</h4>
              <div className="code-example">
                data = {'{'}'a': '1', 'b': '2', 'c': '3'{'}'}<br/>
                reversed_dict = dict()<br/>
                for k, v in data.items():<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;reversed_dict[v] = k<br/>
                print(reversed_dict)<br/>
                # Output: {'{'}'1': 'a', '2': 'b', '3': 'c'{'}'}
              </div>
            </div>
            <div className="example-item">
              <h4>Multiplication Table</h4>
              <div className="code-example">
                n = 3<br/>
                for i in range(1, n + 1):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;for j in range(1, n + 1):<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print(i * j, end=' ')<br/>
                &nbsp;&nbsp;&nbsp;&nbsp;print()<br/>
                # Output:<br/>
                # 1 2 3<br/>
                # 2 4 6<br/>
                # 3 6 9
              </div>
            </div>
            <div className="example-item">
              <h4>Tuple Unpacking</h4>
              <div className="code-example">
                month_abbrevs = ('Jan', 'Feb', 'Mar')<br/>
                first, second, third = month_abbrevs<br/><br/>
                print(first, second, third)<br/>
                # Output: Jan Feb Mar
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
  )
}

export default ExamplesModal
