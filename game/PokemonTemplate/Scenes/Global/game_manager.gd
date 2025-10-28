extends Node2D

var turn = "player"
var is_battle = false
var is_dialog = false
var is_inventory = false  # Flag for inventory state

# Player info
var trainer_name = ""   # Will be set from database

# Inventory system
var captured_pokemon = []  # Array to store captured Pokémon
var total_points = 0       # Total points from captures

func _ready():
	is_battle = false

# Add a captured Pokémon to inventory
func add_pokemon_to_inventory(pokemon_name: String, level: int, points: int):
	var pokemon_data = {
		"name": pokemon_name,
		"level": level,
		"points": points,
		"capture_time": Time.get_datetime_string_from_system()
	}
	captured_pokemon.append(pokemon_data)
	total_points += points
	print("Added to inventory: ", pokemon_name, " Lv", level, " (", points, " points)")
	print("Total Pokémon: ", captured_pokemon.size(), " | Total Points: ", total_points)

# Get all captured Pokémon
func get_captured_pokemon() -> Array:
	return captured_pokemon

# Get total points
func get_total_points() -> int:
	return total_points

# Get trainer name
func get_trainer_name() -> String:
	return trainer_name

# Set trainer name
func set_trainer_name(name: String):
	trainer_name = name

# Get inventory summary
func get_inventory_summary() -> String:
	return "Pokémon: " + str(captured_pokemon.size()) + " | Points: " + str(total_points)
