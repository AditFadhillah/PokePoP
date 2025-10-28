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
	
	# Debug: Set a test trainer name immediately
	trainer_label.text = "Trainer: Debug Test"
	print("World scene ready - set debug trainer name")
	
	# Listen for trainer updates from React
	JSBridge.trainer_updated_from_js.connect(_on_trainer_updated_from_react)
	print("Connected trainer_updated_from_js signal")
	
	# Listen for Pokemon inventory updates from React
	JSBridge.pokemon_inventory_updated_from_js.connect(_on_pokemon_inventory_updated_from_react)
	print("Connected pokemon_inventory_updated_from_js signal")
	
	# Listen for test Pokemon signal from React
	JSBridge.test_pokemon_signal.connect(_on_test_pokemon_signal)
	print("Connected test_pokemon_signal signal")
	
	# Set a default trainer name to avoid requesting from React
	GameManager.set_trainer_name("Test Player")
	setup_trainer_name()
	
	print("🎯 World ready - no trainer data requests to avoid CSV errors")

func _on_trainer_updated_from_react(trainer_name: String):
	# Handle trainer update from React app
	print("RECEIVED TRAINER UPDATE FROM REACT: ", trainer_name)
	GameManager.set_trainer_name(trainer_name)
	
	# Note: Pokemon inventory should be sent separately via POKEMON_INVENTORY_UPDATE message
	# Not loading hardcoded test data here anymore
	
	setup_trainer_name()  # Update the UI
	print("Trainer updated from React:", trainer_name)

func _on_pokemon_inventory_updated_from_react(pokemon_data: Array):
	# Handle Pokemon inventory update from React app
	print("RECEIVED POKEMON INVENTORY UPDATE FROM REACT: ", pokemon_data.size(), " Pokemon")
	GameManager.load_pokemon_from_external_data(pokemon_data)
	print("Pokemon inventory updated from React:", pokemon_data.size(), " Pokemon loaded")

func _on_test_pokemon_signal(pokemon_text: String):
	# Handle test Pokemon signal from React with the actual text
	print("🧪 SUCCESS! TEST_POKEMON signal received from React with text: '", pokemon_text, "'")
	
	# Store the text in the TEST_POKEMON variable
	TEST_POKEMON = pokemon_text
	print("🧪 Stored text in TEST_POKEMON variable: '", TEST_POKEMON, "'")
	
	# Parse the text to find any Pokemon names from the pool
	var found_pokemon = ""
	var pokemon_text_upper = pokemon_text.to_upper()
	
	for pokemon in pokemon_pool:
		if pokemon_text_upper.contains(pokemon):
			found_pokemon = pokemon
			print("🎯 Found Pokemon '", pokemon, "' in text!")
			break
	
	if found_pokemon != "":
		print("🧪 Adding ", found_pokemon, " to inventory via direct add_pokemon_to_inventory call")
		
		# Calculate level and points (you can enhance this logic)
		var level = 1
		var points = level * 100
		
		# Directly call GameManager to add the found Pokemon
		GameManager.add_pokemon_to_inventory(found_pokemon, level, points)
		
		print("🧪 Success! Added ", found_pokemon, " (Level ", level, ", ", points, " pts) to inventory!")
	else:
		print("🚨 No valid Pokemon found in text. Valid Pokemon: ", pokemon_pool)
		print("🚨 Try typing: print('BULBASAUR') or print('PIDGEY') etc.")

func setup_trainer_name():
	# Get trainer name from GameManager
	var trainer_name = GameManager.get_trainer_name()
	print("Setting up trainer name: ", trainer_name)
	if trainer_name == "" or trainer_name == "Ash":  # Default fallback
		trainer_label.text = "Trainer: Loading..."
		print("Using default loading text")
	else:
		trainer_label.text = "Trainer: " + trainer_name
		print("Set trainer label to: ", trainer_label.text)

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
	# Instead of directly adding to inventory, check if there's a pending React capture trigger
	print("TEST: ENTER key pressed - checking for pending capture triggers from React")
	
	# The actual capture should come from React via the capture_triggered_from_js signal
	# This function now just logs that ENTER was pressed
	print("If a Pokemon was captured, it should come from React communication, not hardcoded here")

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
