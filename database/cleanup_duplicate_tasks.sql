-- Clean up duplicate programming tasks
-- This script drops the existing table and recreates it with unique tasks only

-- Drop the existing table and all dependencies
DROP TABLE IF EXISTS public.programming_tasks CASCADE;

-- Recreate the programming_tasks table
CREATE TABLE public.programming_tasks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    starter_code TEXT,
    expected_output TEXT NOT NULL,
    test_cases JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.programming_tasks ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Allow everyone to read tasks
CREATE POLICY "Anyone can view programming tasks" ON public.programming_tasks
    FOR SELECT USING (true);

-- Only authenticated users can insert/update/delete tasks
CREATE POLICY "Admins can manage tasks" ON public.programming_tasks
    FOR ALL USING (auth.uid() IS NOT NULL);

-- Insert 20 unique beginner tasks (dictionaries, loops, nested loops, regex)
INSERT INTO public.programming_tasks (title, description, starter_code, expected_output)
VALUES 
(
    'Count Vowels in String',
    'Write a function count_vowels(text) that counts how many vowels (a,e,i,o,u) are in a string. Use a loop to iterate through the string.',
    'def count_vowels(text):
    # TODO: Count vowels using a loop
    pass

result = count_vowels(''hello world'')
print(result)',
    '5'
),
(
    'Dictionary Key Check',
    'Create a dictionary called pokemon with keys ''name'', ''type'', ''level''. Check if the key ''name'' exists in the dictionary and print True or False.',
    'pokemon = {''name'': ''Pikachu'', ''type'': ''Electric'', ''level'': 25}
# TODO: Check if ''name'' key exists
',
    'True'
),
(
    'Sum List with Loop',
    'Write a function sum_list(numbers) that takes a list of numbers and returns their sum using a for loop (don''t use built-in sum()).',
    'def sum_list(numbers):
    # TODO: Sum numbers using a loop
    pass

result = sum_list([1, 2, 3, 4, 5])
print(result)',
    '15'
),
(
    'Reverse Dictionary',
    'Write a function reverse_dict(input_dict) that swaps keys and values. Given {''a'': ''1'', ''b'': ''2''}, return {''1'': ''a'', ''2'': ''b''}.',
    'def reverse_dict(input_dict):
    # TODO: Swap keys and values
    pass

data = {''a'': ''1'', ''b'': ''2'', ''c'': ''3''}
result = reverse_dict(data)
print(result)',
    '{''1'': ''a'', ''2'': ''b'', ''3'': ''c''}'
),
(
    'Find Email Pattern',
    'Use the re module to check if a string contains a valid email pattern (word@word.word). Return True if found, False otherwise.',
    'import re

def has_email(text):
    # TODO: Check for email pattern using re.search()
    pass

result = has_email(''Contact: user@example.com'')
print(result)',
    'True'
),
(
    'Multiplication Table',
    'Write a function print_table(n) that prints a multiplication table for n using nested loops (rows 1-n, columns 1-n). Print just the number for n=3.',
    'def print_table(n):
    # TODO: Create multiplication table with nested loops
    pass

print_table(3)
# Should print: 1 2 3
#               2 4 6
#               3 6 9',
    '1 2 3
2 4 6
3 6 9'
),
(
    'Count Words in Dictionary',
    'Create a dictionary that counts how many times each word appears in the list [''cat'', ''dog'', ''cat'', ''bird'', ''dog'', ''cat''].',
    'words = [''cat'', ''dog'', ''cat'', ''bird'', ''dog'', ''cat'']
# TODO: Create dictionary with word counts
word_count = {}

print(word_count)',
    '{''cat'': 3, ''dog'': 2, ''bird'': 1}'
),
(
    'Extract Phone Numbers',
    'Use re.findall() to extract all phone numbers in format XXX-XXX-XXXX from text: ''Call 123-456-7890 or 098-765-4321''.',
    'import re

text = ''Call 123-456-7890 or 098-765-4321''
# TODO: Extract phone numbers using re.findall()
phones = 

print(phones)',
    '[''123-456-7890'', ''098-765-4321'']'
),
(
    'Nested Loop Pattern',
    'Use nested loops to print a triangle pattern with asterisks. For n=4, print 4 rows where row i has i asterisks.',
    'n = 4
# TODO: Print triangle pattern using nested loops

',
    '*
**
***
****'
),
(
    'Dictionary Merge',
    'Write a function merge_dicts(dict1, dict2) that combines two dictionaries. If a key exists in both, keep the value from dict2.',
    'def merge_dicts(dict1, dict2):
    # TODO: Merge two dictionaries
    pass

d1 = {''a'': 1, ''b'': 2}
d2 = {''b'': 3, ''c'': 4}
result = merge_dicts(d1, d2)
print(result)',
    '{''a'': 1, ''b'': 3, ''c'': 4}'
),
(
    'Replace Digits',
    'Use re.sub() to replace all digits in a string with ''X''. For ''Code: 123ABC456'', return ''Code: XXXABCXXX''.',
    'import re

text = ''Code: 123ABC456''
# TODO: Replace all digits with ''X''
result = 

print(result)',
    'Code: XXXABCXXX'
),
(
    'Find Even Numbers',
    'Use a for loop to create a list of even numbers from 0 to 20 (inclusive). Use the modulo operator (%).',
    '# TODO: Create list of even numbers using a loop
evens = []

print(evens)',
    '[0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20]'
),
(
    'Dictionary from Two Lists',
    'Create a dictionary from two lists: keys = [''name'', ''age'', ''city''] and values = [''Alice'', 25, ''NYC'']. Use zip() and a loop or dict().',
    'keys = [''name'', ''age'', ''city'']
values = [''Alice'', 25, ''NYC'']
# TODO: Create dictionary from two lists
person = 

print(person)',
    '{''name'': ''Alice'', ''age'': 25, ''city'': ''NYC''}'
),
(
    'Validate Username',
    'Use regex to check if a username is valid: 3-16 characters, only letters, numbers, and underscores. Test with ''user_123''.',
    'import re

def is_valid_username(username):
    # TODO: Check if username matches pattern
    pass

result = is_valid_username(''user_123'')
print(result)',
    'True'
),
(
    'Nested Loop Sum',
    'Use nested loops to calculate the sum of all numbers in a 2D list: [[1,2,3], [4,5,6], [7,8,9]].',
    'matrix = [[1,2,3], [4,5,6], [7,8,9]]
# TODO: Sum all numbers using nested loops
total = 0

print(total)',
    '45'
),
(
    'Get Dictionary Keys',
    'Create a function get_keys_above_value(dictionary, threshold) that returns a list of keys whose values are above the threshold.',
    'def get_keys_above_value(dictionary, threshold):
    # TODO: Find keys with values > threshold
    pass

scores = {''Alice'': 85, ''Bob'': 72, ''Charlie'': 90, ''David'': 68}
result = get_keys_above_value(scores, 75)
print(result)',
    '[''Alice'', ''Charlie'']'
),
(
    'Split by Pattern',
    'Use re.split() to split the text ''apple,banana;cherry orange'' by any of these delimiters: comma, semicolon, or space.',
    'import re

text = ''apple,banana;cherry orange''
# TODO: Split by comma, semicolon, or space
fruits = 

print(fruits)',
    '[''apple'', ''banana'', ''cherry'', ''orange'']'
),
(
    'Loop Through Dictionary',
    'Write a function print_dict(dictionary) that prints each key-value pair in the format ''key: value'' using a for loop.',
    'def print_dict(dictionary):
    # TODO: Print each key-value pair
    pass

data = {''name'': ''Pikachu'', ''type'': ''Electric'', ''level'': 25}
print_dict(data)',
    'name: Pikachu
type: Electric
level: 25'
),
(
    'Find Hashtags',
    'Use regex to find all hashtags (words starting with #) in the text ''Love #Python and #Coding! #Dev''.',
    'import re

text = ''Love #Python and #Coding! #Dev''
# TODO: Find all hashtags using re.findall()
hashtags = 

print(hashtags)',
    '[''#Python'', ''#Coding'', ''#Dev'']'
),
(
    'Nested Dictionary Access',
    'Given a nested dictionary, access and print the value of ''city'' inside ''address''.',
    'person = {
    ''name'': ''Alice'',
    ''age'': 25,
    ''address'': {
        ''street'': ''123 Main St'',
        ''city'': ''NYC'',
        ''zip'': ''10001''
    }
}
# TODO: Access and print the city value
',
    'NYC'
),
(
    'Tuple Unpacking',
    'Create a tuple called month_abbrevs with Jan, Feb, Mar. Then create three variables first_month, second_month, third_month and unpack the tuple into them.',
    '# Create tuple and unpack it
month_abbrevs = (''Jan'', ''Feb'', ''Mar'')
# TODO: Unpack the tuple
',
    'Jan Feb Mar'
),
(
    'Tuple to Lowercase List',
    'Use list comprehension to convert all items in month_abbrevs tuple to lowercase. Store result in month_abbrevs_lower list.',
    'month_abbrevs = (''Jan'', ''Feb'', ''Mar'', ''Apr'')
# TODO: Convert to lowercase using list comprehension
month_abbrevs_lower = 
print(month_abbrevs_lower)',
    '[''jan'', ''feb'', ''mar'', ''apr'']'
),
(
    'Zodiac Reverse Dictionary',
    'Write a function reverse_dict() that exchanges keys and values in a dictionary. Given zodiacs = {"2020":"rat", "2021":"ox", "2022":"tiger", "2023":"rabbit"}, return {''rat'': ''2020'', ''ox'':''2021'', ''tiger'':''2022'', ''rabbit'':''2023''}',
    'def reverse_dict(input_dict):
    # TODO: Implement dictionary reversal
    pass

zodiacs = {"2020":"rat", "2021":"ox", "2022":"tiger", "2023":"rabbit"}
result = reverse_dict(zodiacs)
print(result)',
    '{''rat'': ''2020'', ''ox'': ''2021'', ''tiger'': ''2022'', ''rabbit'': ''2023''}'
),
(
    'DNA to mRNA Transcription',
    'Define transcription(input_sequence, mapping_dict) that translates DNA to mRNA. Use mapping = {''A'':''U'',''T'':''A'',''G'':''C'',''C'':''G''}. For input "TCGTTCAGT", return "AGCAAGUCA".',
    'def transcription(input_sequence, mapping_dict):
    # TODO: Implement DNA to mRNA translation
    pass

input_seq = ''TCGTTCAGT''
mapping = {''A'':''U'',''T'':''A'',''G'':''C'',''C'':''G''}
result = transcription(input_seq, mapping)
print(result)',
    'AGCAAGUCA'
);

-- Recreate the get_random_task function
CREATE OR REPLACE FUNCTION get_random_task()
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    starter_code TEXT,
    expected_output TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.title,
        t.description,
        t.starter_code,
        t.expected_output
    FROM public.programming_tasks t
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Verify the results
SELECT 
    title,
    COUNT(*) as count
FROM public.programming_tasks
GROUP BY title
ORDER BY title;

-- Should show 24 unique tasks, each with count = 1
-- Total count should be 24
SELECT COUNT(*) as total_tasks FROM public.programming_tasks;
