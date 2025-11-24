# Programming Tasks - Solution Cheat Sheet

This document contains the correct solutions for all 24 beginner programming tasks.

## Task Organization by Region

### 🌲 Forest Region - Basic Loops (6 tasks)
Tasks 1, 3, 9, 12, 15, 18 - Focus on for loops, while loops, and iteration

### 🏖️ Beach Region - Dictionaries (7 tasks)  
Tasks 2, 4, 7, 10, 13, 16, 20 - Focus on dictionary operations and methods

### 🌋 Volcano Region - Regex (6 tasks)
Tasks 5, 8, 11, 14, 17, 19 - Focus on regular expressions and pattern matching

### 🐸 Swamp Region - Advanced/Tuples (5 tasks)
Tasks 6, 21, 22, 23, 24 - Focus on tuples, nested structures, and advanced concepts

---

## 1. Count Vowels in String

**Task:** Count vowels (a,e,i,o,u) in a string using a loop.

**Original Task:**
```python
def count_vowels(text):
    # TODO: Count vowels using a loop
    pass

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
print(result)  # Output: 5
```

---

## 2. Dictionary Key Check

**Task:** Check if 'name' key exists in a dictionary.

**Original Task:**
```python
pokemon = {'name': 'Pikachu', 'type': 'Electric', 'level': 25}
# TODO: Check if 'name' key exists
```

**Solution:**
```python
pokemon = {'name': 'Pikachu', 'type': 'Electric', 'level': 25}
# Method 1: Using 'in'
print('name' in pokemon)  # Output: True

# Method 2: Using .get()
print(pokemon.get('name') is not None)  # Output: True
```

---

## 3. Sum List with Loop

**Task:** Sum numbers in a list using a for loop.

**Original Task:**
```python
def sum_list(numbers):
    # TODO: Sum numbers using a loop
    pass

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
print(result)  # Output: 15
```

---

## 4. Reverse Dictionary

**Task:** Swap keys and values in a dictionary.

**Original Task:**
```python
def reverse_dict(input_dict):
    # TODO: Swap keys and values
    pass

data = {'a': '1', 'b': '2', 'c': '3'}
result = reverse_dict(data)
print(result)
```

**Solution:**
```python
def reverse_dict(input_dict):
    return {value: key for key, value in input_dict.items()}

# Alternative solution with loop:
def reverse_dict(input_dict):
    reversed_dict = {}
    for key, value in input_dict.items():
        reversed_dict[value] = key
    return reversed_dict

data = {'a': '1', 'b': '2', 'c': '3'}
result = reverse_dict(data)
print(result)  # Output: {'1': 'a', '2': 'b', '3': 'c'}
```

---

## 5. Find Email Pattern

**Task:** Check if string contains an email using regex.

**Original Task:**
```python
import re

def has_email(text):
    # TODO: Check for email pattern using re.search()
    pass

result = has_email('Contact: user@example.com')
print(result)
```

**Solution:**
```python
import re

def has_email(text):
    pattern = r'\w+@\w+\.\w+'
    return re.search(pattern, text) is not None

result = has_email('Contact: user@example.com')
print(result)  # Output: True
```

**Pattern Explanation:**
- `\w+` = one or more word characters (letters, digits, underscore)
- `@` = literal @ symbol
- `\.` = literal dot (escaped)

---

## 6. Multiplication Table

**Task:** Print multiplication table using nested loops.

**Original Task:**
```python
def print_table(n):
    # TODO: Create multiplication table with nested loops
    pass

print_table(3)
# Should print: 1 2 3
#               2 4 6
#               3 6 9
```

**Solution:**
```python
def print_table(n):
    for i in range(1, n+1):
        for j in range(1, n+1):
            print(i * j, end=' ')
        print()  # New line after each row

print_table(3)
# Output:
# 1 2 3
# 2 4 6
# 3 6 9
```

---

## 7. Count Words in Dictionary

**Task:** Count word occurrences in a list.

**Original Task:**
```python
words = ['cat', 'dog', 'cat', 'bird', 'dog', 'cat']
# TODO: Create dictionary with word counts
word_count = {}

print(word_count)
```

**Solution:**
```python
words = ['cat', 'dog', 'cat', 'bird', 'dog', 'cat']

# Method 1: Using loop
word_count = {}
for word in words:
    if word in word_count:
        word_count[word] += 1
    else:
        word_count[word] = 1

# Method 2: Using .get()
word_count = {}
for word in words:
    word_count[word] = word_count.get(word, 0) + 1

print(word_count)  # Output: {'cat': 3, 'dog': 2, 'bird': 1}
```

---

## 8. Extract Phone Numbers

**Task:** Extract phone numbers in format XXX-XXX-XXXX using regex.

**Original Task:**
```python
import re

text = 'Call 123-456-7890 or 098-765-4321'
# TODO: Extract phone numbers using re.findall()
phones = 

print(phones)
```

**Solution:**
```python
import re

text = 'Call 123-456-7890 or 098-765-4321'
phones = re.findall(r'\d{3}-\d{3}-\d{4}', text)

print(phones)  # Output: ['123-456-7890', '098-765-4321']
```

**Pattern Explanation:**
- `\d{3}` = exactly 3 digits
- `-` = literal hyphen
- Pattern matches XXX-XXX-XXXX format

---

## 9. Nested Loop Pattern

**Task:** Print triangle pattern with asterisks.

**Original Task:**
```python
n = 4
# TODO: Print triangle pattern using nested loops
```

**Solution:**
```python
n = 4
for i in range(1, n+1):
    for j in range(i):
        print('*', end='')
    print()  # New line after each row

# Output:
# *
# **
# ***
# ****
```

---

## 10. Dictionary Merge

**Task:** Merge two dictionaries, dict2 values override dict1.

**Original Task:**
```python
def merge_dicts(dict1, dict2):
    # TODO: Merge two dictionaries
    pass

d1 = {'a': 1, 'b': 2}
d2 = {'b': 3, 'c': 4}
result = merge_dicts(d1, d2)
print(result)
```

**Solution:**
```python
def merge_dicts(dict1, dict2):
    merged = dict1.copy()  # Don't modify original
    merged.update(dict2)
    return merged

# Alternative (Python 3.9+):
def merge_dicts(dict1, dict2):
    return dict1 | dict2

d1 = {'a': 1, 'b': 2}
d2 = {'b': 3, 'c': 4}
result = merge_dicts(d1, d2)
print(result)  # Output: {'a': 1, 'b': 3, 'c': 4}
```

---

## 11. Replace Digits

**Task:** Replace all digits with 'X' using regex.

**Original Task:**
```python
import re

text = 'Code: 123ABC456'
# TODO: Replace all digits with 'X'
result = 

print(result)
```

**Solution:**
```python
import re

text = 'Code: 123ABC456'
result = re.sub(r'\d', 'X', text)

print(result)  # Output: Code: XXXABCXXX
```

**Pattern Explanation:**
- `\d` = any digit (0-9)
- `re.sub(pattern, replacement, text)` replaces all matches

---

## 12. Find Even Numbers

**Task:** Create list of even numbers from 0 to 20.

**Original Task:**
```python
# TODO: Create list of even numbers in the range of 0 to 20 using a loop
evens = []

print(evens)
```

**Solution:**
```python
# Method 1: Using loop
evens = []
for i in range(21):
    if i % 2 == 0:
        evens.append(i)

# Method 2: List comprehension
evens = [i for i in range(21) if i % 2 == 0]

# Method 3: Using range step
evens = list(range(0, 21, 2))

print(evens)  # Output: [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
```

---

## 13. Dictionary from Two Lists

**Task:** Create dictionary from keys and values lists.

**Original Task:**
```python
keys = ['name', 'age', 'city']
values = ['Alice', 25, 'NYC']
# TODO: Create dictionary from two lists
person = 

print(person)
```

**Solution:**
```python
keys = ['name', 'age', 'city']
values = ['Alice', 25, 'NYC']

# Method 1: Using dict() and zip()
person = dict(zip(keys, values))

# Method 2: Using dictionary comprehension
person = {keys[i]: values[i] for i in range(len(keys))}

# Method 3: Using loop
person = {}
for i in range(len(keys)):
    person[keys[i]] = values[i]

print(person)  # Output: {'name': 'Alice', 'age': 25, 'city': 'NYC'}
```

---

## 14. Validate Username

**Task:** Check if username is valid (3-16 chars, letters/numbers/underscore only).

**Original Task:**
```python
import re

def is_valid_username(username):
    # TODO: Check if username matches pattern
    pass

result = is_valid_username('user_123')
print(result)
```

**Solution:**
```python
import re

def is_valid_username(username):
    pattern = r'^[a-zA-Z0-9_]{3,16}$'
    return re.match(pattern, username) is not None

result = is_valid_username('user_123')
print(result)  # Output: True
```

**Pattern Explanation:**
- `^` = start of string
- `[a-zA-Z0-9_]` = letters, digits, or underscore
- `{3,16}` = between 3 and 16 characters
- `$` = end of string

---

## 15. Nested Loop Sum

**Task:** Sum all numbers in a 2D list using nested loops.

**Original Task:**
```python
matrix = [[1,2,3], [4,5,6], [7,8,9]]
# TODO: Sum all numbers using nested loops
total = 0

print(total)
```

**Solution:**
```python
matrix = [[1,2,3], [4,5,6], [7,8,9]]
total = 0

for row in matrix:
    for num in row:
        total += num

print(total)  # Output: 45
```

---

## 16. Get Dictionary Keys

**Task:** Return keys with values above a threshold.

**Original Task:**
```python
def get_keys_above_value(dictionary, threshold):
    # TODO: Find keys with values > threshold
    pass

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

# Alternative with list comprehension:
def get_keys_above_value(dictionary, threshold):
    return [key for key, value in dictionary.items() if value > threshold]

scores = {'Alice': 85, 'Bob': 72, 'Charlie': 90, 'David': 68}
result = get_keys_above_value(scores, 75)
print(result)  # Output: ['Alice', 'Charlie']
```

---

## 17. Split by Pattern

**Task:** Split text by comma, semicolon, or space using regex.

**Original Task:**
```python
import re

text = 'apple,banana;cherry orange'
# TODO: Split by comma, semicolon, or space
fruits = 

print(fruits)
```

**Solution:**
```python
import re

text = 'apple,banana;cherry orange'
fruits = re.split(r'[,; ]+', text)

print(fruits)  # Output: ['apple', 'banana', 'cherry', 'orange']
```

**Pattern Explanation:**
- `[,; ]` = character class matching comma, semicolon, or space
- `+` = one or more occurrences

---

## 18. Loop Through Dictionary

**Task:** Print each key-value pair in format 'key: value'.

**Original Task:**
```python
def print_dict(dictionary):
    # TODO: Print each key-value pair
    pass

data = {'name': 'Pikachu', 'type': 'Electric', 'level': 25}
print_dict(data)
```

**Solution:**
```python
def print_dict(dictionary):
    for key, value in dictionary.items():
        print(f'{key}: {value}')

data = {'name': 'Pikachu', 'type': 'Electric', 'level': 25}
print_dict(data)

# Output:
# name: Pikachu
# type: Electric
# level: 25
```

---

## 19. Find Hashtags

**Task:** Extract all hashtags (words starting with #) using regex.

**Original Task:**
```python
import re

text = 'Love #Python and #Coding! #Dev'
# TODO: Find all hashtags using re.findall()
hashtags = 

print(hashtags)
```

**Solution:**
```python
import re

text = 'Love #Python and #Coding! #Dev'
hashtags = re.findall(r'#\w+', text)

print(hashtags)  # Output: ['#Python', '#Coding', '#Dev']
```

**Pattern Explanation:**
- `#` = literal hashtag symbol
- `\w+` = one or more word characters (letters, digits, underscore)

---

## 20. Nested Dictionary Access

**Task:** Access 'city' value from nested dictionary.

**Original Task:**
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
# TODO: Access and print the city value
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

# Access nested value
city = person['address']['city']
print(city)  # Output: NYC

# Safe access with .get()
city = person.get('address', {}).get('city', 'Unknown')
print(city)  # Output: NYC
```

---

## 21. Tuple Unpacking

**Task:** Unpack tuple into three separate variables.

**Original Task:**
```python
# Create tuple and unpack it
month_abbrevs = ('Jan', 'Feb', 'Mar')
# TODO: Unpack the tuple
```

**Solution:**
```python
# Create tuple and unpack it
month_abbrevs = ('Jan', 'Feb', 'Mar')
first_month, second_month, third_month = month_abbrevs

print(first_month, second_month, third_month)  # Output: Jan Feb Mar
```

---

## 22. Tuple to Lowercase List

**Task:** Convert tuple items to lowercase using list comprehension.

**Original Task:**
```python
month_abbrevs = ('Jan', 'Feb', 'Mar', 'Apr')
# TODO: Convert to lowercase using list comprehension
month_abbrevs_lower = 
print(month_abbrevs_lower)
```

**Solution:**
```python
month_abbrevs = ('Jan', 'Feb', 'Mar', 'Apr')
month_abbrevs_lower = [month.lower() for month in month_abbrevs]
print(month_abbrevs_lower)  # Output: ['jan', 'feb', 'mar', 'apr']
```

---

## 23. Zodiac Reverse Dictionary

**Task:** Exchange keys and values for zodiac dictionary.

**Original Task:**
```python
def reverse_dict(input_dict):
    # TODO: Implement dictionary reversal
    pass

zodiacs = {"2020":"rat", "2021":"ox", "2022":"tiger", "2023":"rabbit"}
result = reverse_dict(zodiacs)
print(result)
```

**Solution:**
```python
def reverse_dict(input_dict):
    return {value: key for key, value in input_dict.items()}

zodiacs = {"2020":"rat", "2021":"ox", "2022":"tiger", "2023":"rabbit"}
result = reverse_dict(zodiacs)
print(result)  # Output: {'rat': '2020', 'ox': '2021', 'tiger': '2022', 'rabbit': '2023'}
```

---

## 24. DNA to mRNA Transcription

**Task:** Translate DNA sequence to mRNA using mapping dictionary.

**Original Task:**
```python
def transcription(input_sequence, mapping_dict):
    # TODO: Implement DNA to mRNA translation
    pass

input_seq = 'TCGTTCAGT'
mapping = {'A':'U','T':'A','G':'C','C':'G'}
result = transcription(input_seq, mapping)
print(result)
```

**Solution:**
```python
def transcription(input_sequence, mapping_dict):
    result = ''
    for char in input_sequence:
        result += mapping_dict[char]
    return result

# Alternative with list comprehension:
def transcription(input_sequence, mapping_dict):
    return ''.join([mapping_dict[char] for char in input_sequence])

input_seq = 'TCGTTCAGT'
mapping = {'A':'U','T':'A','G':'C','C':'G'}
result = transcription(input_seq, mapping)
print(result)  # Output: AGCAAGUCA
```

---

## Quick Reference

### Common Regex Patterns
- `\d` = digit (0-9)
- `\w` = word character (a-z, A-Z, 0-9, _)
- `\s` = whitespace
- `+` = one or more
- `*` = zero or more
- `{n,m}` = between n and m occurrences
- `^` = start of string
- `$` = end of string
- `[abc]` = character class (a, b, or c)

### Dictionary Methods
- `dict.keys()` = get all keys
- `dict.values()` = get all values
- `dict.items()` = get key-value pairs
- `dict.get(key, default)` = safe access
- `dict.update(other_dict)` = merge dictionaries
- `key in dict` = check if key exists

### Loop Patterns
```python
# Simple loop
for item in list:
    # process item

# Loop with index
for i in range(len(list)):
    # use list[i]

# Loop through dictionary
for key, value in dict.items():
    # process key and value

# Nested loop
for i in range(n):
    for j in range(m):
        # process i, j
```
