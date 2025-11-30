# Programming Tasks Solutions

## Analysis Summary

### Tasks Incorrectly Categorized
The following tasks are labeled with loop-related categories but don't primarily focus on loops:
- **Nested Dictionary Access** (Beach) - Dictionary access operation
- **Dictionary Key Check** (Beach) - Membership testing with `in` keyword
- **Dictionary from Two Lists** (Beach) - Uses `zip()` function
- **Tuple Unpacking** (Swamp) - Tuple unpacking operation
- **Reverse Dictionary** (Swamp) - Can use comprehension or loop
- **Dictionary Merge** (Beach) - Dictionary update operations

---

## Forest Category (Loop-focused)

### 1. Loop Through Dictionary
**Description:** Write a function print_dict(dictionary) that prints each key-value pair in the format 'key: value' using a for loop.

**Starter Code:**
```python
def print_dict(dictionary):
    # TODO: Print each key-value pair
    for ... in ...:
        print(...)
    

data = {'name': 'Pikachu', 'type': 'Electric', 'level': 25}
print_dict(data)
```

**Solution:**
```python
def print_dict(dictionary):
    for key, value in dictionary.items():
        print(f"{key}: {value}")

data = {'name': 'Pikachu', 'type': 'Electric', 'level': 25}
print_dict(data)
```

**Output:**
```
name: Pikachu
type: Electric
level: 25
```

---

### 2. Count Vowels in String
**Description:** Write a function count_vowels(text) that counts how many vowels (a,e,i,o,u) are in a string. Use a loop to iterate through the string.

**Starter Code:**
```python
def count_vowels(text):
    # TODO: Count vowels using a loop
    for ... in ...:

    return ...
    

result = count_vowels('hello world')
print(result)
```

**Solution:**
```python
def count_vowels(text):
    vowels = 'aeiouAEIOU'
    count = 0
    for char in text:
        if char in vowels:
            count += 1
    return count

result = count_vowels('hello world')
print(result)
```

**Output:**
```
3
```

---

### 3. Nested Loop Pattern
**Description:** Use nested loops to print a triangle pattern with asterisks. For n=4, print 4 rows where row i has i asterisks.

**Starter Code:**
```python
n = 4
# TODO: Print triangle pattern using nested loops
for ... in ...:
    for ... in ...:
        print(...)
    print()

# *
# **
# ***
# ****
```

**Solution:**
```python
n = 4
for i in range(1, n + 1):
    for j in range(i):
        print('*', end='')
    print()
```

**Output:**
```
*
**
***
****
```

---

### 4. Sum List with Loop
**Description:** Write a function sum_list(numbers) that takes a list of numbers and returns their sum using a for loop (don't use built-in sum()).

**Starter Code:**
```python
def sum_list(numbers):
    # TODO: Sum numbers using a loop
    for ... in ...:

    return ...

result = sum_list([1, 2, 3, 4, 5])
print(result)
```

**Solution:**
```python
def sum_list(numbers):
    total = 0
    for num in numbers:
        total += num
    return total

result = sum_list([1, 2, 3, 4, 5])
print(result)
```

**Output:**
```
15
```

---

### 5. Nested Loop Sum
**Description:** Use nested loops to calculate the sum of all numbers in a 2D list: [[1,2,3], [4,5,6], [7,8,9]].

**Starter Code:**
```python
matrix = [[1,2,3], [4,5,6], [7,8,9]]
# TODO: Sum all numbers using nested loops
# Outer loop: iterate through each row
# Inner loop: iterate through each number in the row
total = 0
for ... in ...:
    for ... in ...:

print(total)
```

**Solution:**
```python
matrix = [[1,2,3], [4,5,6], [7,8,9]]
total = 0
for row in matrix:
    for num in row:
        total += num

print(total)
```

**Output:**
```
45
```

---

### 6. Find Even Numbers
**Description:** Use a for loop to create a list of even numbers from 0 to 20 (inclusive). Use the modulo operator (%).

**Starter Code:**
```python
# TODO: Create list of even numbers in the range of 0 to 20 using a loop
evens = []
for ... in ...:

print(evens)
```

**Solution:**
```python
evens = []
for num in range(21):
    if num % 2 == 0:
        evens.append(num)

print(evens)
```

**Output:**
```
[0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
```

---

### 7. List Filtering with Loop
**Description:** Write a function filter_long_words(words, min_length) that returns a list of words longer than min_length. Use a for loop to iterate through the list.

**Starter Code:**
```python
def filter_long_words(words, min_length):
    # TODO: Filter words based on length using a loop
    result = []
    for ... in ...:

    return result

word_list = ['cat', 'elephant', 'dog', 'butterfly', 'ox']
result = filter_long_words(word_list, 5)
print(result)
```

**Solution:**
```python
  def filter_long_words(words, min_length):
      result = []
      for word in words:
          if len(word) > min_length:
              result.append(word)
      return result

  word_list = ['cat', 'elephant', 'dog', 'butterfly', 'ox']
  result = filter_long_words(word_list, 5)
  print(result)
```

**Output:**
```
['elephant', 'butterfly']
```

---

### 8. Matrix Maximum
**Description:** Use nested loops to find the maximum value in a 2D list (matrix). Don't use built-in max() function.

**Starter Code:**
```python
matrix = [[3, 7, 2], [8, 1, 9], [4, 6, 5]]
# TODO: Find maximum value using nested loops
# Initialize max_val with first element
max_val = matrix[0][0]
for ... in ...:
    for ... in ...:
      ...

print(max_val)
```

**Solution:**
```python
matrix = [[3, 7, 2], [8, 1, 9], [4, 6, 5]]
max_val = matrix[0][0]
for row in matrix:
    for num in row:
        if num > max_val:
            max_val = num

print(max_val)
```

**Output:**
```
9
```

---

### 9. Count Characters
**Description:** Write a function that counts how many times each character appears in a string using a loop. Return a dictionary with character frequencies.

**Starter Code:**
```python
def count_characters(text):
    # TODO: Count character frequencies using a loop
    char_count = {}
    for ... in ...:

    return char_count

result = count_characters('hello')
print(result)
```

**Solution:**
```python
def count_characters(text):
    char_count = {}
    for char in text:
        if char in char_count:
            char_count[char] += 1
        else:
            char_count[char] = 1
    return char_count

result = count_characters('hello')
print(result)
```

**Output:**
```
{'h': 1, 'e': 1, 'l': 2, 'o': 1}
```

---

### 10. Nested Loop Coordinates
**Description:** Use nested loops to print all coordinate pairs (x, y) where x ranges from 0 to 2 and y ranges from 0 to 2. Use range(...).

**Starter Code:**
```python
# TODO: Print all (x,y) coordinates using nested loops
for x in ...:
    for y in ...:
        print(...)
```

**Solution:**
```python
for x in range(3):
    for y in range(3):
        print(f"({x}, {y})")
```

**Output:**
```
(0, 0)
(0, 1)
(0, 2)
(1, 0)
(1, 1)
(1, 2)
(2, 0)
(2, 1)
(2, 2)
```

---

## Beach Category (Dictionary-focused)

### 11. Create Simple Dictionary
**Description:** Create a dictionary with three key-value pairs: 'name' = 'Ash', 'age' = 10, 'city' = 'Pallet Town'. Then print the entire dictionary.

**Starter Code:**
```python
# TODO: Create a dictionary with name, age, and city
trainer = ...

print(trainer)
```

**Solution:**
```python
trainer = {'name': 'Ash', 'age': 10, 'city': 'Pallet Town'}
print(trainer)
```

**Output:**
```
{'name': 'Ash', 'age': 10, 'city': 'Pallet Town'}
```

---

### 12. Nested Dictionary Access
**Description:** Given a nested dictionary, access and print the value of 'city' inside 'address'.

**Starter Code:**
```python
person = {
    'name': 'Alice',
    'age': 25,
    'address': {
        'street': '123 Main St',
        'city': 'NYC',
        'zip': '10001'
    }
}
# TODO: Access and print the city value from the nested address dictionary
# Hint: person['...']['...']
```

**Solution:**
```python
person = {
    'name': 'Alice',
    'age': 25,
    'address': {
        'street': '123 Main St',
        'city': 'NYC',
        'zip': '10001'
    }
}
print(person['address']['city'])
```

**Output:**
```
NYC
```

---

### 13. Dictionary Merge
**Description:** Write a function merge_dicts(dict1, dict2) that combines two dictionaries. If a key exists in both, keep the value from dict2.

**Starter Code:**
```python
def merge_dicts(dict1, dict2):
    # TODO: Merge two dictionaries

    return ...

d1 = {'a': 1, 'b': 2}
d2 = {'b': 3, 'c': 4}
result = merge_dicts(d1, d2)
print(result)
```

**Solution:**
```python
def merge_dicts(dict1, dict2):
    merged = dict1.copy()
    merged.update(dict2)
    return merged

d1 = {'a': 1, 'b': 2}
d2 = {'b': 3, 'c': 4}
result = merge_dicts(d1, d2)
print(result)
```

**Output:**
```
{'a': 1, 'b': 3, 'c': 4}
```

---

### 14. Get Dictionary Keys
**Description:** Create a function get_keys_above_value(dictionary, threshold) that returns a list of keys whose values are above the threshold.

**Starter Code:**
```python
def get_keys_above_value(dictionary, threshold):
    # TODO: Find keys with values > threshold
    for ... in ...:

    return ...

scores = {'Alice': 85, 'Bob': 72, 'Charlie': 90, 'David': 68}
result = get_keys_above_value(scores, 75)
print(result)
```

**Solution:**
```python
def get_keys_above_value(dictionary, threshold):
    result = []
    for key, value in dictionary.items():
        if value > threshold:
            result.append(key)
    return result

scores = {'Alice': 85, 'Bob': 72, 'Charlie': 90, 'David': 68}
result = get_keys_above_value(scores, 75)
print(result)
```

**Output:**
```
['Alice', 'Charlie']
```

---

### 15. Dictionary from Two Lists ⭐
**Description:** Create a dictionary from two lists using zip() and dict(), or a dictionary comprehension.

**Starter Code:**
```python
keys = ['name', 'age', 'city']
values = ['Alice', 25, 'NYC']
# TODO: Create dictionary from two lists
person = ...

print(person)
```

**Solution:**
```python
keys = ['name', 'age', 'city']
values = ['Alice', 25, 'NYC']
person = dict(zip(keys, values))

print(person)
```

**Output:**
```
{'name': 'Alice', 'age': 25, 'city': 'NYC'}
```

---

### 16. Dictionary Key Check ⭐
**Description:** Create a dictionary called pokemon with keys 'name', 'type', 'level'. Check if the key 'name' exists in the dictionary and print True or False.

**Starter Code:**
```python
pokemon = {'name': 'Pikachu', 'type': 'Electric', 'level': 25}
# TODO: Check if 'name' key exists in the dictionary
result = ...
print(result)
```

**Solution:**
```python
pokemon = {'name': 'Pikachu', 'type': 'Electric', 'level': 25}
result = 'name' in pokemon
print(result)
```

**Output:**
```
True
```

---

### 17. Zodiac Reverse Dictionary (Dict Comprehension) ⭐
**Description:** Write a function reverse_dict() that exchanges keys and values in a dictionary. Use dictionary comprehension. Assume both keys and values are unique.

**Starter Code:**
```python
def reverse_dict(input_dict):
    # TODO: Use dictionary comprehension to swap keys and values
    # Hint: {value: key for key, value in input_dict.items()}
    return ...

zodiacs = {"2020":"rat", "2021":"ox", "2022":"tiger", "2023":"rabbit"}
result = reverse_dict(zodiacs)
print(result)
```

**Solution:**
```python
def reverse_dict(input_dict):
    '''Dictionary Reversal using dict comprehension'''
    return {value: key for key, value in input_dict.items()}

zodiacs = {"2020":"rat", "2021":"ox", "2022":"tiger", "2023":"rabbit"}
result = reverse_dict(zodiacs)
print(result)
```

**Output:**
```
{'rat': '2020', 'ox': '2021', 'tiger': '2022', 'rabbit': '2023'}
```

---

### 18. Count Words in Dictionary
**Description:** Create a dictionary that counts how many times each word appears in the list ['cat', 'dog', 'cat', 'bird', 'dog', 'cat'].

**Starter Code:**
```python
words = ['cat', 'dog', 'cat', 'bird', 'dog', 'cat']
# TODO: Create dictionary with word counts
# Loop through words and count occurrences
word_count = {}
for ... in ...:

print(word_count)
```

**Solution:**
```python
words = ['cat', 'dog', 'cat', 'bird', 'dog', 'cat']
word_count = {}
for word in words:
    if word in word_count:
        word_count[word] += 1
    else:
        word_count[word] = 1

print(word_count)
```

**Output:**
```
{'cat': 3, 'dog': 2, 'bird': 1}
```

---

## Swamp Category (Mixed Concepts)

### 19. Reverse Dictionary with For Loop ⭐
**Description:** Write a function reverse_dict(input_dict) that swaps keys and values using a for loop. Given {'a': '1', 'b': '2'}, return {'1': 'a', '2': 'b'}. Assume both keys and values are unique.

**Starter Code:**
```python
def reverse_dict(input_dict):
    '''Dictionary Reversal'''
    reversed_dict = dict()
    # TODO: For loop over dictionary items
    for ... in ...:
    return ...

data = {'a': '1', 'b': '2', 'c': '3'}
result = reverse_dict(data)
print(result)
```

**Solution:**
```python
def reverse_dict(input_dict):
    '''Dictionary Reversal'''
    reversed_dict = dict()
    # For loop over dictionary items
    for k, v in input_dict.items():
        reversed_dict[v] = k
    return reversed_dict

data = {'a': '1', 'b': '2', 'c': '3'}
result = reverse_dict(data)
print(result)
```

**Output:**
```
{'1': 'a', '2': 'b', '3': 'c'}
```

---

### 20. Multiplication Table
**Description:** Write a function print_table(n) that prints a multiplication table for n using nested loops (rows 1-n, columns 1-n).

**Starter Code:**
```python
def print_table(n):
    # TODO: Create multiplication table with nested loops
    for ... in ...:
        for ... in ...: 
        print()

print_table(3)
# Should print: 1 2 3
#               2 4 6
#               3 6 9
```

**Solution:**
```python
def print_table(n):
    for i in range(1, n + 1):
        for j in range(1, n + 1):
            print(i * j, end=' ')
        print()

print_table(3)
```

**Output:**
```
1 2 3
2 4 6
3 6 9
```

---

### 21. Tuple to Lowercase List ⭐
**Description:** Use list comprehension to convert all items in month_abbrevs tuple to lowercase. Store result in month_abbrevs_lower list. Note: Python doesn't have true tuple comprehension - using parentheses with comprehension creates a generator, so we use list comprehension.

**Starter Code:**
```python
month_abbrevs = ('Jan', 'Feb', 'Mar', 'Apr')
# TODO: Convert to lowercase using list comprehension
month_abbrevs_lower = ...
print(month_abbrevs_lower)
```

**Solution:**
```python
month_abbrevs = ('Jan', 'Feb', 'Mar', 'Apr')
# List comprehension to convert tuple items to lowercase
month_abbrevs_lower = [s.lower() for s in month_abbrevs]
print(month_abbrevs_lower)
```

**Output:**
```
['jan', 'feb', 'mar', 'apr']
```

---

### 22. Tuple Unpacking ⭐
**Description:** Create a tuple with month abbreviations, then unpack it into three separate variables and print them separated by spaces. If you try to unpack a tuple with 4 items into 3 variables, Python raises a ValueError.

**Starter Code:**
```python
# Create tuple and unpack it
month_abbrevs = ('Jan', 'Feb', 'Mar')
# TODO: Unpack the tuple into three variables
...

# Then print them separated by spaces
print(first_month, second_month, third_month)
```

**Solution:**
```python
month_abbrevs = ('Jan', 'Feb', 'Mar')

# Initialize 3 variables with the tuple
first_month, second_month, third_month = month_abbrevs
print(first_month, second_month, third_month)
```

**Output:**
```
Jan Feb Mar
```

---

### 23. Create and Access Tuple
**Description:** Create a tuple containing three Pokemon names: 'Pikachu', 'Charmander', 'Bulbasaur'. Access and print the second Pokemon (index 1).

**Starter Code:**
```python
# TODO: Create a tuple with three Pokemon names: 
# Pikachu', 'Charmander', 'Bulbasaur' in this order
pokemon_tuple = ...

# TODO: Access and print the second element (index 1)
print(...)
```

**Solution:**
```python
pokemon_tuple = ('Pikachu', 'Charmander', 'Bulbasaur')
print(pokemon_tuple[1])
```

**Output:**
```
Charmander
```

---

### 24. Tuple Length and Index
**Description:** Given a tuple of colors, find its length and find the index of the color 'blue'. Use len() and .index() methods.

**Starter Code:**
```python
colors = ('red', 'green', 'blue', 'yellow', 'purple')
# TODO: Print the length of the tuple
print(...)
# TODO: Find and print the index of 'blue'
print(...)
```

**Solution:**
```python
colors = ('red', 'green', 'blue', 'yellow', 'purple')
print(len(colors))
print(colors.index('blue'))
```

**Output:**
```
5
2
```

---

### 25. DNA to mRNA Transcription ⭐
**Description:** Define transcription(input_sequence, mapping_dict) that translates DNA to mRNA. When input_sequence contains illegal characters, print error message and return an empty string.

**Starter Code:**
```python
def transcription(input_sequence, mapping_dict):
    # TODO: Implement DNA to mRNA translation
    for ... in ...:
    
    return ...

input_seq = 'TCGTTCAGT'
mapping = {'A':'U','T':'A','G':'C','C':'G'}
result = transcription(input_seq, mapping)
print(result)
```

**Solution:**
```python
def transcription(input_sequence, mapping_dict):
    '''DNA to mRNA translation with error handling'''
    output_sequence = ''
    for c in input_sequence:
        if c not in mapping_dict:
            print('Illegal input DNA sequence.')
            return ''
        output_sequence = output_sequence + mapping_dict[c]
    return output_sequence

input_seq = 'TCGTTCAGT'
mapping = {'A':'U','T':'A','G':'C','C':'G'}
result = transcription(input_seq, mapping)
print(result)
```

**Output:**
```
AGCAAGUCA
```

---

## Volcano Category (Regex-focused)

### 26. Find Word with Regex
**Description:** Use re.search() to check if the word 'Python' appears in a string. Return True if found, False otherwise.

**Starter Code:**
```python
import re

def has_python(text):
    # TODO: Check for 'Python' pattern using re.search()
    ...
    return bool(...)

result = has_python('I love Python programming')
print(result)
```

**Solution:**
```python
import re

def has_python(text):
    pattern = r'Python'
    return bool(re.search(pattern, text))

result = has_python('I love Python programming')
print(result)
```

**Output:**
```
True
```

---

### 27. Replace Letter
**Description:** Use re.sub() to replace all letter 'a' with 'o' in a string. For example, 'cat and rat' should become 'cot ond rot'.

**Starter Code:**
```python
import re

text = 'cat and rat'
# TODO: Replace all 'a' with 'o' using re.sub()
result = ...

print(result)
```

**Solution:**
```python
import re

text = 'cat and rat'
result = re.sub(r'a', 'o', text)

print(result)
```

**Output:**
```
cot ond rot
```

---

### 28. Find All Numbers
**Description:** Use re.findall() to find all single-digit numbers in the text. Return them as a list.

**Starter Code:**
```python
import re

text = 'I have 3 cats and 2 dogs'
# TODO: Find all digits using re.findall()
numbers = ...

print(numbers)
```

**Solution:**
```python
import re

text = 'I have 3 cats and 2 dogs'
numbers = re.findall(r'\d', text)

print(numbers)
```

**Output:**
```
['3', '2']
```

---

### 29. Split by Comma
**Description:** Use re.split() to split text by comma. Return a list of words.

**Starter Code:**
```python
import re

text = 'apple,banana,cherry,orange'
# TODO: Split by comma using re.split()
fruits = ...

print(fruits)
```

**Solution:**
```python
import re

text = 'apple,banana,cherry,orange'
fruits = re.split(r',', text)

print(fruits)
```

**Output:**
```
['apple', 'banana', 'cherry', 'orange']
```

---

### 30. Find All Words
**Description:** Use re.findall() to find all words (sequences of letters) in the text. Return them as a list.

**Starter Code:**
```python
import re

text = 'Hello123 World456 Test'
# TODO: Find all letter sequences using re.findall()
words = ...

print(words)
```

**Solution:**
```python
import re

text = 'Hello123 World456 Test'
words = re.findall(r'[A-Za-z]+', text)

print(words)
```

**Output:**
```
['Hello', 'World', 'Test']
```

---

### 31. Check if Starts with Letter
**Description:** Use re.match() to check if a string starts with a letter (uppercase or lowercase). Test with 'Hello123'.

**Starter Code:**
```python
import re

def starts_with_letter(text):
    # TODO: Check if text matches pattern
    ...
    return bool(...)

result = starts_with_letter('Hello123')
print(result)
```

**Solution:**
```python
import re

def starts_with_letter(text):
    pattern = r'^[A-Za-z]'
    return bool(re.match(pattern, text))

result = starts_with_letter('Hello123')
print(result)
```

**Output:**
```
True
```

---

## Summary Statistics

- **Total Tasks:** 31
- **Loop-focused Tasks:** 10 (Forest)
- **Dictionary Tasks:** 8 (Beach)
- **Mixed Concepts Tasks:** 8 (Swamp - includes tuple operations, nested loops, and dictionary with loops)
- **Regex Tasks:** 6 (Volcano)

### Task Distribution by Category
**Forest (Loop-focused):**
1. Loop Through Dictionary
2. Count Vowels in String
3. Nested Loop Pattern
4. Sum List with Loop
5. Nested Loop Sum
6. Find Even Numbers
7. List Filtering with Loop
8. Matrix Maximum
9. Count Characters
10. Nested Loop Coordinates

**Beach (Dictionary-focused):**
11. Create Simple Dictionary
12. Nested Dictionary Access
13. Dictionary Merge
14. Get Dictionary Keys
15. Dictionary from Two Lists ⭐ Professor's Task
16. Dictionary Key Check ⭐ Professor's Task
17. Zodiac Reverse Dictionary (Dict Comprehension) ⭐ Professor's Task
18. Count Words in Dictionary

**Swamp (Mixed Concepts - Tuples, Nested Loops, Dictionary+Loops):**
19. Reverse Dictionary with For Loop ⭐ Professor's Task (Alternative approach)
20. Multiplication Table
21. Tuple to Lowercase List ⭐ Professor's Task
22. Tuple Unpacking ⭐ Professor's Task
23. Create and Access Tuple
24. Tuple Length and Index
25. DNA to mRNA Transcription ⭐ Professor's Task

**Volcano (Regex-focused):**
26. Find Word with Regex
27. Replace Letter
28. Find All Numbers
29. Split by Comma
30. Find All Words
31. Check if Starts with Letter

### Professor's Tasks Integration
All tasks from the professor's worksheet (w04_monday_worksheet_solution) are properly included:
- **Task #15 (Beach)**: Dictionary from Two Lists using zip()
- **Task #16 (Beach)**: Dictionary Key Check with 'in' keyword
- **Task #17 (Beach)**: Zodiac Reverse Dictionary using dictionary comprehension
- **Task #19 (Swamp)**: Reverse Dictionary using explicit for loop (alternative approach to show loop mechanics)
- **Task #20 (Swamp)**: Multiplication Table with nested loops (rows 1-n, columns 1-n)
- **Task #21-22 (Swamp)**: Tuple operations (lowercase conversion, unpacking)
- **Task #25 (Swamp)**: DNA to mRNA transcription with error handling

**Note:** The Dictionary Reversal concept appears twice with different approaches:
1. **Task #17 (Beach)** - Dictionary comprehension (concise, Pythonic)
2. **Task #19 (Swamp)** - Explicit for loop (educational, demonstrates iteration)
