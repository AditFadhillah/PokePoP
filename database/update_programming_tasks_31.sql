-- Update programming_tasks table with all 31 tasks from programming_tasks_solutions.md
-- This includes the new Forest tasks and Swamp tuple tasks

-- First, clear existing tasks
TRUNCATE TABLE programming_tasks;

-- Insert all 31 tasks in correct order

-- FOREST CATEGORY (Tasks 1-10)
INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Loop Through Dictionary', 'Write a function print_dict(dictionary) that prints each key-value pair in the format ''key: value'' using a for loop.', 
'def print_dict(dictionary):
    # TODO: Print each key-value pair
    for ... in ...:
        print(...)
    

data = {''name'': ''Pikachu'', ''type'': ''Electric'', ''level'': 25}
print_dict(data)', 
'name: Pikachu
type: Electric
level: 25', 
'Forest', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Count Vowels in String', 'Write a function count_vowels(text) that counts how many vowels (a,e,i,o,u) are in a string. Use a loop to iterate through the string.', 
'def count_vowels(text):
    # TODO: Count vowels using a loop
    for ... in ...:

    return ...
    

result = count_vowels(''hello world'')
print(result)', 
'3', 
'Forest', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Nested Loop Pattern', 'Use nested loops to print a triangle pattern with asterisks. For n=4, print 4 rows where row i has i asterisks.', 
'n = 4
# TODO: Print triangle pattern using nested loops
for ... in ...:
    for ... in ...:
        print(...)
    print()

# *
# **
# ***
# ****', 
'*
**
***
****', 
'Forest', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Sum List with Loop', 'Write a function sum_list(numbers) that takes a list of numbers and returns their sum using a for loop (don''t use built-in sum()).', 
'def sum_list(numbers):
    # TODO: Sum numbers using a loop
    for ... in ...:

    return ...

result = sum_list([1, 2, 3, 4, 5])
print(result)', 
'15', 
'Forest', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Nested Loop Sum', 'Use nested loops to calculate the sum of all numbers in a 2D list: [[1,2,3], [4,5,6], [7,8,9]].', 
'matrix = [[1,2,3], [4,5,6], [7,8,9]]
# TODO: Sum all numbers using nested loops
# Outer loop: iterate through each row
# Inner loop: iterate through each number in the row
total = 0
for ... in ...:
    for ... in ...:

print(total)', 
'45', 
'Forest', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Find Even Numbers', 'Use a for loop to create a list of even numbers from 0 to 20 (inclusive). Use the modulo operator (%).', 
'# TODO: Create list of even numbers in the range of 0 to 20 using a loop
evens = []
for ... in ...:

print(evens)', 
'[0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20]', 
'Forest', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'List Filtering with Loop', 'Write a function filter_long_words(words, min_length) that returns a list of words longer than min_length. Use a for loop to iterate through the list.', 
'def filter_long_words(words, min_length):
    # TODO: Filter words based on length using a loop
    result = []
    for ... in ...:

    return result

word_list = [''cat'', ''elephant'', ''dog'', ''butterfly'', ''ox'']
result = filter_long_words(word_list, 5)
print(result)', 
'[''elephant'', ''butterfly'']', 
'Forest', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Matrix Maximum', 'Use nested loops to find the maximum value in a 2D list (matrix). Don''t use built-in max() function.', 
'matrix = [[3, 7, 2], [8, 1, 9], [4, 6, 5]]
# TODO: Find maximum value using nested loops
# Initialize max_val with first element
max_val = matrix[0][0]
for ... in ...:
    for ... in ...:
      ...

print(max_val)', 
'9', 
'Forest', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Count Characters', 'Write a function that counts how many times each character appears in a string using a loop. Return a dictionary with character frequencies.', 
'def count_characters(text):
    # TODO: Count character frequencies using a loop
    char_count = {}
    for ... in ...:

    return char_count

result = count_characters(''hello'')
print(result)', 
'{''h'': 1, ''e'': 1, ''l'': 2, ''o'': 1}', 
'Forest', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Nested Loop Coordinates', 'Use nested loops to print all coordinate pairs (x, y) where x ranges from 0 to 2 and y ranges from 0 to 2. Use range(...).', 
'# TODO: Print all (x,y) coordinates using nested loops
for x in ...:
    for y in ...:
        print(...)', 
'(0, 0)
(0, 1)
(0, 2)
(1, 0)
(1, 1)
(1, 2)
(2, 0)
(2, 1)
(2, 2)', 
'Forest', NOW(), NOW());

-- BEACH CATEGORY (Tasks 11-18)
INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Create Simple Dictionary', 'Create a dictionary with three key-value pairs: ''name'' = ''Ash'', ''age'' = 10, ''city'' = ''Pallet Town''. Then print the entire dictionary.', 
'# TODO: Create a dictionary with name, age, and city
trainer = ...

print(trainer)', 
'{''name'': ''Ash'', ''age'': 10, ''city'': ''Pallet Town''}', 
'Beach', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Nested Dictionary Access', 'Given a nested dictionary, access and print the value of ''city'' inside ''address''.', 
'person = {
    ''name'': ''Alice'',
    ''age'': 25,
    ''address'': {
        ''street'': ''123 Main St'',
        ''city'': ''NYC'',
        ''zip'': ''10001''
    }
}
# TODO: Access and print the city value from the nested address dictionary
# Hint: person[''...''][''...'']
', 
'NYC', 
'Beach', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Dictionary Merge', 'Write a function merge_dicts(dict1, dict2) that combines two dictionaries. If a key exists in both, keep the value from dict2.', 
'def merge_dicts(dict1, dict2):
    # TODO: Merge two dictionaries

    return ...

d1 = {''a'': 1, ''b'': 2}
d2 = {''b'': 3, ''c'': 4}
result = merge_dicts(d1, d2)
print(result)', 
'{''a'': 1, ''b'': 3, ''c'': 4}', 
'Beach', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Get Dictionary Keys', 'Create a function get_keys_above_value(dictionary, threshold) that returns a list of keys whose values are above the threshold.', 
'def get_keys_above_value(dictionary, threshold):
    # TODO: Find keys with values > threshold
    for ... in ...:

    return ...

scores = {''Alice'': 85, ''Bob'': 72, ''Charlie'': 90, ''David'': 68}
result = get_keys_above_value(scores, 75)
print(result)', 
'[''Alice'', ''Charlie'']', 
'Beach', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Dictionary from Two Lists ⭐', 'Create a dictionary from two lists using zip() and dict(), or a dictionary comprehension.', 
'keys = [''name'', ''age'', ''city'']
values = [''Alice'', 25, ''NYC'']
# TODO: Create dictionary from two lists
person = ...

print(person)', 
'{''name'': ''Alice'', ''age'': 25, ''city'': ''NYC''}', 
'Beach', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Dictionary Key Check ⭐', 'Create a dictionary called pokemon with keys ''name'', ''type'', ''level''. Check if the key ''name'' exists in the dictionary and print True or False.', 
'pokemon = {''name'': ''Pikachu'', ''type'': ''Electric'', ''level'': 25}
# TODO: Check if ''name'' key exists in the dictionary
result = ...
print(result)', 
'True', 
'Beach', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Zodiac Reverse Dictionary (Dict Comprehension) ⭐', 'Write a function reverse_dict() that exchanges keys and values in a dictionary. Use dictionary comprehension. Assume both keys and values are unique.', 
'def reverse_dict(input_dict):
    # TODO: Use dictionary comprehension to swap keys and values
    # Hint: {value: key for key, value in input_dict.items()}
    return ...

zodiacs = {"2020":"rat", "2021":"ox", "2022":"tiger", "2023":"rabbit"}
result = reverse_dict(zodiacs)
print(result)', 
'{''rat'': ''2020'', ''ox'': ''2021'', ''tiger'': ''2022'', ''rabbit'': ''2023''}', 
'Beach', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Count Words in Dictionary', 'Create a dictionary that counts how many times each word appears in the list [''cat'', ''dog'', ''cat'', ''bird'', ''dog'', ''cat''].', 
'words = [''cat'', ''dog'', ''cat'', ''bird'', ''dog'', ''cat'']
# TODO: Create dictionary with word counts
# Loop through words and count occurrences
word_count = {}
for ... in ...:

print(word_count)', 
'{''cat'': 3, ''dog'': 2, ''bird'': 1}', 
'Beach', NOW(), NOW());

-- SWAMP CATEGORY (Tasks 19-25)
INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Reverse Dictionary with For Loop ⭐', 'Write a function reverse_dict(input_dict) that swaps keys and values using a for loop. Given {''a'': ''1'', ''b'': ''2''}, return {''1'': ''a'', ''2'': ''b''}. Assume both keys and values are unique.', 
'def reverse_dict(input_dict):
    ''''''Dictionary Reversal''''''
    reversed_dict = dict()
    # TODO: For loop over dictionary items
    for ... in ...:
    return ...

data = {''a'': ''1'', ''b'': ''2'', ''c'': ''3''}
result = reverse_dict(data)
print(result)', 
'{''1'': ''a'', ''2'': ''b'', ''3'': ''c''}', 
'Swamp', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Multiplication Table', 'Write a function print_table(n) that prints a multiplication table for n using nested loops (rows 1-n, columns 1-n).', 
'def print_table(n):
    # TODO: Create multiplication table with nested loops
    for ... in ...:
        for ... in ...: 
        print()

print_table(3)
# Should print: 1 2 3
#               2 4 6
#               3 6 9', 
'1 2 3
2 4 6
3 6 9', 
'Swamp', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Tuple to Lowercase List ⭐', 'Use list comprehension to convert all items in month_abbrevs tuple to lowercase. Store result in month_abbrevs_lower list. Note: Python doesn''t have true tuple comprehension - using parentheses with comprehension creates a generator, so we use list comprehension.', 
'month_abbrevs = (''Jan'', ''Feb'', ''Mar'', ''Apr'')
# TODO: Convert to lowercase using list comprehension
month_abbrevs_lower = ...
print(month_abbrevs_lower)', 
'[''jan'', ''feb'', ''mar'', ''apr'']', 
'Swamp', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Tuple Unpacking ⭐', 'Create a tuple with month abbreviations, then unpack it into three separate variables and print them separated by spaces. If you try to unpack a tuple with 4 items into 3 variables, Python raises a ValueError.', 
'# Create tuple and unpack it
month_abbrevs = (''Jan'', ''Feb'', ''Mar'')
# TODO: Unpack the tuple into three variables
...

# Then print them separated by spaces
print(first_month, second_month, third_month)', 
'Jan Feb Mar', 
'Swamp', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Create and Access Tuple', 'Create a tuple containing three Pokemon names: ''Pikachu'', ''Charmander'', ''Bulbasaur''. Access and print the second Pokemon (index 1).', 
'# TODO: Create a tuple with three Pokemon names: 
# Pikachu'', ''Charmander'', ''Bulbasaur'' in this order
pokemon_tuple = ...

# TODO: Access and print the second element (index 1)
print(...)', 
'Charmander', 
'Swamp', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Tuple Length and Index', 'Given a tuple of colors, find its length and find the index of the color ''blue''. Use len() and .index() methods.', 
'colors = (''red'', ''green'', ''blue'', ''yellow'', ''purple'')
# TODO: Print the length of the tuple
print(...)
# TODO: Find and print the index of ''blue''
print(...)', 
'5
2', 
'Swamp', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'DNA to mRNA Transcription ⭐', 'Define transcription(input_sequence, mapping_dict) that translates DNA to mRNA. When input_sequence contains illegal characters, print error message and return an empty string.', 
'def transcription(input_sequence, mapping_dict):
    # TODO: Implement DNA to mRNA translation
    for ... in ...:
    
    return ...

input_seq = ''TCGTTCAGT''
mapping = {''A'':''U'',''T'':''A'',''G'':''C'',''C'':''G''}
result = transcription(input_seq, mapping)
print(result)', 
'AGCAAGUCA', 
'Swamp', NOW(), NOW());

-- VOLCANO CATEGORY (Tasks 26-31)
INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Find Word with Regex', 'Use re.search() to check if the word ''Python'' appears in a string. Return True if found, False otherwise.', 
'import re

def has_python(text):
    # TODO: Check for ''Python'' pattern using re.search()
    ...
    return bool(...)

result = has_python(''I love Python programming'')
print(result)', 
'True', 
'Volcano', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Replace Letter', 'Use re.sub() to replace all letter ''a'' with ''o'' in a string. For example, ''cat and rat'' should become ''cot ond rot''.', 
'import re

text = ''cat and rat''
# TODO: Replace all ''a'' with ''o'' using re.sub()
result = ...

print(result)', 
'cot ond rot', 
'Volcano', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Find All Numbers', 'Use re.findall() to find all single-digit numbers in the text. Return them as a list.', 
'import re

text = ''I have 3 cats and 2 dogs''
# TODO: Find all digits using re.findall()
numbers = ...

print(numbers)', 
'[''3'', ''2'']', 
'Volcano', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Split by Comma', 'Use re.split() to split text by comma. Return a list of words.', 
'import re

text = ''apple,banana,cherry,orange''
# TODO: Split by comma using re.split()
fruits = ...

print(fruits)', 
'[''apple'', ''banana'', ''cherry'', ''orange'']', 
'Volcano', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Find All Words', 'Use re.findall() to find all words (sequences of letters) in the text. Return them as a list.', 
'import re

text = ''Hello123 World456 Test''
# TODO: Find all letter sequences using re.findall()
words = ...

print(words)', 
'[''Hello'', ''World'', ''Test'']', 
'Volcano', NOW(), NOW());

INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Check if Starts with Letter', 'Use re.match() to check if a string starts with a letter (uppercase or lowercase). Test with ''Hello123''.', 
'import re

def starts_with_letter(text):
    # TODO: Check if text matches pattern
    ...
    return bool(...)

result = starts_with_letter(''Hello123'')
print(result)', 
'True', 
'Volcano', NOW(), NOW());

-- Verify the count
SELECT category, COUNT(*) as task_count 
FROM programming_tasks 
GROUP BY category 
ORDER BY category;

-- Show total count (should be 31)
SELECT COUNT(*) as total_tasks FROM programming_tasks;
