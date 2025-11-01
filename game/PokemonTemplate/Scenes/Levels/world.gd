extends Node2D

@onready var world_music = $LittleRootTownMusic
@onready var trainer_label = $UI/TrainerLabel
@onready var inventory_indicator = $UI/InventoryIndicator
@onready var ui_layer = $UI

var inventory_scene = preload("res://Scenes/UI/inventory.tscn")

# Variable to store the test Pokemon text from React
var TEST_POKEMON = ""

# Pokemon pool for parsing from text
var pokemon_pool = ["BULBASAUR", "CATERPIE", "EEVEE", "PIDGEY", "VULPIX", "RATTATA"]

func _ready():
	world_music.play()
	
	# Listen for trainer updates from React
	JSBridge.trainer_updated_from_js.connect(_on_trainer_updated_from_react)
	
	# Listen for Pokemon inventory updates from React
	JSBridge.pokemon_inventory_updated_from_js.connect(_on_pokemon_inventory_updated_from_react)
	
	# Listen for test Pokemon signal from React
	JSBridge.test_pokemon_signal.connect(_on_test_pokemon_signal)
	
	# Set initial trainer label to show waiting state
	trainer_label.text = "Trainer: Select a trainer"

func _on_trainer_updated_from_react(trainer_name: String):
	# Handle trainer update from React app
	GameManager.set_trainer_name(trainer_name)
	setup_trainer_name()

func _on_pokemon_inventory_updated_from_react(pokemon_data: Array):
	# Handle Pokemon inventory update from React app
	GameManager.load_pokemon_from_external_data(pokemon_data)

func _on_test_pokemon_signal(pokemon_text: String):
	# Handle test Pokemon signal from React with the actual text
	TEST_POKEMON = pokemon_text
	
	# Parse the text to find any Pokemon names from the pool
	var found_pokemon = ""
	var pokemon_text_upper = pokemon_text.to_upper()
	
	for pokemon in pokemon_pool:
		if pokemon_text_upper.contains(pokemon):
			found_pokemon = pokemon
			break
	
	if found_pokemon != "":
		var level = 1
		var points = level * 100
		GameManager.add_pokemon_to_inventory(found_pokemon, level, points)

func setup_trainer_name():
	# Get trainer name from GameManager
	var trainer_name = GameManager.get_trainer_name()
	if trainer_name == "":
		trainer_label.text = "Trainer: Select a trainer"
	else:
		trainer_label.text = "Trainer: " + trainer_name

func _process(delta):
	# Control music playing
	if (GameManager.is_battle or GameManager.is_inventory) and world_music.is_playing():
		world_music.stop()
	
	if !GameManager.is_battle and !GameManager.is_inventory and !world_music.is_playing():
		world_music.play()
	
	# Control UI visibility during battle
	update_ui_visibility()
	
	# Handle inventory input (E key)
	if Input.is_action_just_pressed("inventory") and !GameManager.is_battle and !GameManager.is_inventory:
		open_inventory()
	
	# Test: Capture Pokemon button (ENTER key) - restored functionality
	if Input.is_action_just_pressed("ui_accept") and !GameManager.is_battle and !GameManager.is_inventory:
		test_capture_pokemon()

func test_capture_pokemon():
	# Test function for ENTER key press
	# Actual captures should come from React via signals
	pass

func update_ui_visibility():
	# Hide UI elements during battle, show them otherwise
	var should_show_ui = !GameManager.is_battle
	
	# Option 1: Hide individual elements
	trainer_label.visible = should_show_ui
	inventory_indicator.visible = should_show_ui
	
	# Option 2: Alternatively, you could hide the entire UI layer
	# ui_layer.visible = should_show_ui

func open_inventory():
	GameManager.is_inventory = true
	var inventory_instance = inventory_scene.instantiate()
	get_tree().current_scene.add_child(inventory_instance)
