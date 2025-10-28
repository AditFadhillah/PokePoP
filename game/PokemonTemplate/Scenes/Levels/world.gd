extends Node2D

@onready var world_music = $LittleRootTownMusic
@onready var trainer_label = $UI/TrainerLabel
@onready var inventory_indicator = $UI/InventoryIndicator
@onready var ui_layer = $UI

var inventory_scene = preload("res://Scenes/UI/inventory.tscn")

func _ready():
	world_music.play()
	
	# Debug: Set a test trainer name immediately
	trainer_label.text = "Trainer: Debug Test"
	print("World scene ready - set debug trainer name")
	
	# Test: After 3 seconds, manually set GameManager trainer name and update UI
	await get_tree().create_timer(3.0).timeout
	GameManager.set_trainer_name("tester")
	setup_trainer_name()  # This should now show "tester"
	print("Updated GameManager trainer name to 'tester' and refreshed UI")
	
	# Request current trainer from React app
	JSBridge.send_message_to_react("request_current_trainer", {})
	print("Sent request_current_trainer message to React")
	
	# Listen for trainer updates from React
	JSBridge.trainer_updated_from_js.connect(_on_trainer_updated_from_react)
	print("Connected trainer_updated_from_js signal")
	
	# Don't call setup_trainer_name() here initially since we're testing

func _on_trainer_updated_from_react(trainer_name: String):
	# Handle trainer update from React app
	print("RECEIVED TRAINER UPDATE FROM REACT: ", trainer_name)
	GameManager.set_trainer_name(trainer_name)
	setup_trainer_name()  # Update the UI
	print("Trainer updated from React:", trainer_name)

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
