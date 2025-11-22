extends Node

# Signals
signal pokemon_inventory_changed

# Game state variables
var turn = "player"
var is_battle = false
var is_dialog = false
var is_inventory = false

# Trainer and Pokemon data
var trainer_name = ""
var captured_pokemon = []
var total_points = 0

func _ready():
	is_battle = false

# Trainer management functions
func set_trainer_name(name: String):
	trainer_name = name

func get_trainer_name() -> String:
	return trainer_name

# Pokemon inventory management
func add_pokemon_to_inventory(pokemon_name: String, level: int, points: int):
	var pokemon_data = {
		"name": pokemon_name,
		"level": level,
		"points": points,
		"captured_at": Time.get_datetime_string_from_system()
	}
	captured_pokemon.append(pokemon_data)
	total_points += points
	
	# Emit signal to notify UI components
	pokemon_inventory_changed.emit()

func get_captured_pokemon() -> Array:
	return captured_pokemon

func get_total_points() -> int:
	return total_points

func load_pokemon_from_external_data(pokemon_data: Array):
	# Clear existing and load new data
	captured_pokemon.clear()
	total_points = 0
	
	for pokemon in pokemon_data:
		if typeof(pokemon) == TYPE_DICTIONARY:
			var pokemon_dict = {
				"name": pokemon.get("pokemon_name", "Unknown"),
				"level": int(pokemon.get("level", 1)),
				"points": int(pokemon.get("points", 100)),
				"captured_at": pokemon.get("captured_at", Time.get_datetime_string_from_system())
			}
			captured_pokemon.append(pokemon_dict)
			total_points += pokemon_dict.points
	
	# Emit signal to notify UI components
	pokemon_inventory_changed.emit()
