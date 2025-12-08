-- Add 3 new dictionary tasks to Beach region
-- This brings Beach region from 8 to 11 tasks, making total 34 tasks

-- Task 32: Dictionary Update Value
INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Dictionary Update Value', 'Write a function update_level(pokemon_dict, new_level) that updates the ''level'' key in the dictionary to the new_level value. Return the updated dictionary.', 
'def update_level(pokemon_dict, new_level):
    # TODO: Update the level value in the dictionary
    ...
    return pokemon_dict

pokemon = {''name'': ''Pikachu'', ''type'': ''Electric'', ''level'': 25}
result = update_level(pokemon, 30)
print(result)', 
'{''name'': ''Pikachu'', ''type'': ''Electric'', ''level'': 30}', 
'Beach', NOW(), NOW());

-- Task 33: Dictionary Get with Default
INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Dictionary Get with Default', 'Use the .get() method to retrieve the value for key ''hp'' from a pokemon dictionary. If the key doesn''t exist, return the default value 100.', 
'pokemon = {''name'': ''Pikachu'', ''type'': ''Electric'', ''level'': 25}
# TODO: Use .get() method to retrieve ''hp'' with default 100
hp = ...

print(hp)', 
'100', 
'Beach', NOW(), NOW());

-- Task 34: Dictionary Values Sum
INSERT INTO programming_tasks (id, title, description, starter_code, expected_output, category, created_at, updated_at) VALUES
(gen_random_uuid(), 'Dictionary Values Sum', 'Write a function sum_stats(stats_dict) that takes a dictionary of stat names and values, and returns the sum of all values using a loop.', 
'def sum_stats(stats_dict):
    # TODO: Sum all values in the dictionary using a loop
    total = 0
    for ... in ...:
        ...
    return total

stats = {''hp'': 45, ''attack'': 49, ''defense'': 49, ''speed'': 45}
result = sum_stats(stats)
print(result)', 
'188', 
'Beach', NOW(), NOW());
