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
var total_points_override = -1  # -1 means no override, use calculated value

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
	# If we have an override value from the database (includes achievement points), use it
	if total_points_override >= 0:
		return total_points_override
	return total_points

func set_total_points_override(points: int):
	# Set the total points from database (includes pokemon + achievement points)
	total_points_override = points
	print("✨ Total points override set to: ", points, " (includes achievement bonus)")
	# Emit signal to update UI
	pokemon_inventory_changed.emit()

func load_pokemon_from_external_data(pokemon_data: Array, total_points_from_db: int = -1):
	# If total_points from database is provided, use it as override FIRST
	if total_points_from_db >= 0:
		total_points_override = total_points_from_db
		print("✨ Total points override set to: ", total_points_from_db, " (includes achievement bonus from database)")
	else:
		# Reset override if not provided
		total_points_override = -1
	
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
	
	# Emit signal to notify UI components (override is already set above)
	pokemon_inventory_changed.emit()
