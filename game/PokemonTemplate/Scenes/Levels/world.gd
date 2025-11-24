extends Node2D

@onready var world_music = $LittleRootTownMusic
@onready var trainer_label = $UI/TrainerLabel
@onready var inventory_indicator = $UI/InventoryIndicator
@onready var interact_indicator = $UI/InteractIndicator
@onready var ui_layer = $UI

var inventory_scene = preload("res://Scenes/UI/inventory.tscn")
var sign_scene = preload("res://Scenes/UI/sign_display.tscn")
var welcome_scene = preload("res://Scenes/UI/welcome_display.tscn")

# Sign messages dictionary - maps tile coordinates to messages
var sign_messages = {
	Vector2i(2, 2): "Welcome to Flower Village!\nTasks: Basic Loops",
	Vector2i(15, 9): "Check Tall Grass to find Pokemons!",
	Vector2i(12, 14): "Every region has different unique Pokemons!",
	Vector2i(18, 2): "Twin Lotus Pond",
	Vector2i(20, 9): "The door is locked",
	Vector2i(6, 11): "Probably shouldn't enter a strangers house",
	Vector2i(9, 18): "Probably shouldn't enter a strangers house",
	Vector2i(7, 18): "Probably shouldn't enter a strangers house",
	Vector2i(17, 18): "Probably shouldn't enter a strangers house",
	Vector2i(3, 14): "It's a tree",

	Vector2i(38, 9): "Welcome to Sunny Beach\nTasks: Dictionaries",
	Vector2i(40, 14): "Check Washed-up Seaweed to find Pokemons!",
	Vector2i(47, 7): "Beautiful sand castle, careful not to step on it!",
	Vector2i(48, 7): "Beautiful sand castle, careful not to step on it!",
	Vector2i(48, 12): "Beautiful sand castle, careful not to step on it!",
	Vector2i(35, 14): "It's a palm tree",
	
	Vector2i(40, 30): "Welcome to Mangrove Swamp\nTasks: Tuples",
	Vector2i(40, 28): "Check Tall Grass to find Pokemons!",
	Vector2i(44, 32): "The cave is blocked off",
	Vector2i(47, 35): "Overgrown plants blocks the entrance",
	Vector2i(36, 37): "It's a scary cave, luckily it's blocked off",
	Vector2i(34, 33): "It's a tree",

	Vector2i(15, 29): "Welcome to Barren Volcano\nTasks: Regular Expressions",
	Vector2i(17, 29): "Check Rocks with Orange Crystals to find Pokemons!",
	Vector2i(18, 32): "LAVA LAKE AHEAD, WALK WITH CAUTION!",
	Vector2i(20, 29): "It's a big rock",

	
}

var sign_displayed = false
var player_node = null
var welcome_shown = false

func _ready():
	world_music.play()
	
	# Listen for trainer updates from React
	JSBridge.trainer_updated_from_js.connect(_on_trainer_updated_from_react)
	
	# Listen for Pokemon inventory updates from React
	JSBridge.pokemon_inventory_updated_from_js.connect(_on_pokemon_inventory_updated_from_react)
	
	# Set initial trainer label to show waiting state
	trainer_label.text = "Trainer: ..."
	
	# Get reference to player
	player_node = get_node_or_null("Player")
	
	# Show welcome message when game starts
	await get_tree().create_timer(0.5).timeout
	show_welcome_message("Welcome to PyMon \nMove with WASD or Arrow Keys!")
	welcome_shown = true

func _on_trainer_updated_from_react(trainer_name: String):
	# Handle trainer update from React app
	GameManager.set_trainer_name(trainer_name)
	setup_trainer_name()

func _on_pokemon_inventory_updated_from_react(pokemon_data: Array, total_points: int):
	# Handle Pokemon inventory update from React app with total points from database
	GameManager.load_pokemon_from_external_data(pokemon_data, total_points)

func setup_trainer_name():
	# Get trainer name from GameManager
	var trainer_name = GameManager.get_trainer_name()
	if trainer_name == "":
		trainer_label.text = "Trainer: ..."
	else:
		trainer_label.text = "Trainer: " + trainer_name

func _process(_delta):
	# Control music playing (don't stop music for signs or inventory)
	if GameManager.is_battle and world_music.is_playing():
		world_music.stop()
	
	if !GameManager.is_battle and !world_music.is_playing():
		world_music.play()
	
	# Control UI visibility during battle
	update_ui_visibility()
	
	# Handle inventory input (E key)
	if Input.is_action_just_pressed("inventory") and !GameManager.is_battle and !GameManager.is_inventory and !sign_displayed:
		open_inventory()
	
	# Check for nearby signs
	check_sign_interaction()

func update_ui_visibility():
	# Hide UI elements during battle, show them otherwise
	var should_show_ui = !GameManager.is_battle
	
	# Option 1: Hide individual elements
	trainer_label.visible = should_show_ui
	inventory_indicator.visible = should_show_ui
	interact_indicator.visible = should_show_ui
	
	# Option 2: Alternatively, you could hide the entire UI layer
	# ui_layer.visible = should_show_ui

func open_inventory():
	GameManager.is_inventory = true
	var inventory_instance = inventory_scene.instantiate()
	get_tree().current_scene.add_child(inventory_instance)

func check_sign_interaction():
	# Try to find player if not already set
	if !player_node:
		player_node = get_node_or_null("Player")
		if !player_node:
			return
	
	# Check if player is near a sign and press interaction key
	if GameManager.is_battle or GameManager.is_inventory or sign_displayed:
		return
	
	# Get player's tile position
	var player_pos = player_node.global_position
	var tile_pos = Vector2i(int(player_pos.x / 16), int(player_pos.y / 16))
	
	# Check adjacent tiles (one block away in all 4 directions)
	var adjacent_positions = [
		tile_pos,  # Current position
		tile_pos + Vector2i(0, -1),  # Up
		tile_pos + Vector2i(0, 1),   # Down
		tile_pos + Vector2i(-1, 0),  # Left
		tile_pos + Vector2i(1, 0)    # Right
	]
	
	# Check if player presses F key near a sign (using direct key check)
	if Input.is_physical_key_pressed(KEY_F):
		for adj_pos in adjacent_positions:
			if sign_messages.has(adj_pos):
				show_sign(sign_messages[adj_pos])
				# Add small delay to prevent multiple triggers
				await get_tree().create_timer(0.2).timeout
				return

func show_sign(message: String):
	sign_displayed = true
	var sign_instance = sign_scene.instantiate()
	sign_instance.set_message(message)
	get_tree().current_scene.add_child(sign_instance)
	
	# Connect to sign's closed signal to reset flag
	sign_instance.tree_exited.connect(_on_sign_closed)

func _on_sign_closed():
	sign_displayed = false

func show_welcome_message(message: String):
	sign_displayed = true
	var welcome_instance = welcome_scene.instantiate()
	welcome_instance.set_message(message)
	get_tree().current_scene.add_child(welcome_instance)
	
	# Wait for first message to close, then show second message
	await welcome_instance.tree_exited
	sign_displayed = false
	
	# Wait a brief moment before showing second message
	await get_tree().create_timer(0.3).timeout
	
	# Show second welcome message
	sign_displayed = true
	var second_welcome = welcome_scene.instantiate()
	second_welcome.set_message("Press F to interact with signs \nPress E to check inventory")
	get_tree().current_scene.add_child(second_welcome)
	
	# Connect to second message's closed signal to reset flag
	second_welcome.tree_exited.connect(_on_sign_closed)
