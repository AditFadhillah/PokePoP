@tool
extends Control

@onready var enemy = $CanvasLayer/Enemy
@onready var attack_btn = $CanvasLayer/UI/PlayerMenu/FightMenu/AttackBtn1
@onready var run_btn = $CanvasLayer/UI/PlayerMenu/FightMenu/RunBtn
@onready var enemy_hp_bar = $CanvasLayer/Enemy/EnemyHPBar
@onready var anim = $CanvasLayer/AnimationPlayer
@onready var text_timer = $CanvasLayer/UI/DialogBox/TextTimer
@onready var dialog =$CanvasLayer/UI/DialogBox/RichTextLabel
@onready var dialog_box = $CanvasLayer/UI/DialogBox
@onready var click_to_continue = $CanvasLayer/UI/DialogBox/ContinueArrow
@onready var menu = $CanvasLayer/UI/PlayerMenu
@onready var menu_arrow = $CanvasLayer/UI/PlayerMenu/FightMenu/MenuArrow
@onready var player = $CanvasLayer/Player
@onready var canvas = $CanvasLayer

@export var text_speed = 0.04

var text_num = 0
var is_dialog_finished = false
var is_menu_visible = false
var begin_battle = false
var capture_in_progress = false  # Flag to prevent input during capture

# Battle timer variables
var battle_timer = 100.0  # 10 seconds
var time_remaining = 100.0
var timer_active = false
var timer_label: Label

# Region-based Pokemon pools
var pokemon_pools = {
	"Forest": ["RATTATA", "CATERPIE", "EEVEE", "VULPIX", "BULBASAUR", "PIDGEY"],
	"Beach": ["SQUIRTLE", "HORSEA", "MEOWTH", "KRABBY", "SEEL", "MAGIKARP"],
	"Volcano": ["CHARMANDER", "DIGLETT", "CUBONE", "RHYHORN", "PONYTA", "GEODUDE"],
	"Swamp": ["GRIMER", "GASTLY", "ODDISH", "ZUBAT", "VENONAT", "EKANS"]
}

# Rare Pokemon that can appear in any region (low probability)
var rare_pokemon = ["VAPOREON", "JOLTEON", "FLAREON", "DITTO", "MEW", "PIKACHU_CATCH"]
var rare_probability = 0.05  # 5% chance for rare Pokemon

var current_pokemon = ""
var current_region = ""

func _ready():
	SignalManager.connect("btn_pos", move_menu_arrow)
	SignalManager.connect("player_animation_finished", on_player_animation_finished)
	SignalManager.connect("enemy_animation_finished", on_enemy_animation_finished)
	SignalManager.connect("enemy_dead", on_enemy_dead)
	SignalManager.connect("player_dead", on_player_dead)
	
	# Connect to JSBridge for task completion
	if JSBridge:
		JSBridge.task_completed_from_js.connect(_on_task_completed)
		print("✅ Battle script connected to task completion signal (v2)")
	
	# Create timer label
	create_timer_label()
	
	# Select Pokemon based on region (will be set by set_region before _ready)
	select_pokemon_for_region()

	# Generate random level (1-3 for variety)
	var random_level = randi_range(1, 3)
	
	# Set the enemy to display the selected Pokemon
	enemy.set_pokemon(current_pokemon, random_level)
	
	# Update button text to reflect capture mechanic
	attack_btn.text = "CAPTURE"
	
	anim.play("fade_in")
	dialog_box.visible = true
	dialog.visible = false	
	$BattleMusic.play()

func create_timer_label():
	# Timer label creation (kept hidden from player, only console logs visible)
	# No visual timer needed - creates suspense!
	pass

func set_region(region: String):
	# Called by player.gd before adding to scene tree
	current_region = region
	print("Battle region set to: ", region)

func select_pokemon_for_region():
	# Check for rare Pokemon first (5% chance)
	if randf() < rare_probability:
		current_pokemon = rare_pokemon[randi() % rare_pokemon.size()]
		print("Rare Pokemon encountered: ", current_pokemon)
		return
	
	# Get Pokemon pool for the current region
	if pokemon_pools.has(current_region):
		var region_pool = pokemon_pools[current_region]
		current_pokemon = region_pool[randi() % region_pool.size()]
		print("Region Pokemon encountered in ", current_region, ": ", current_pokemon)
	else:
		# Fallback to Forest if region not found
		print("Warning: Unknown region '", current_region, "', using Forest")
		var forest_pool = pokemon_pools["Forest"]
		current_pokemon = forest_pool[randi() % forest_pool.size()]

func _process(delta):
	click_to_continue.visible = is_dialog_finished
	
	if begin_battle:
		show_dialog("A wild " + current_pokemon + " appeared!")
		begin_battle = false
		
	# Update battle timer (hidden from player for suspense)
	if timer_active and !capture_in_progress:
		time_remaining -= delta
		
		# Console countdown every second (for debugging/tracking only)
		var current_second = int(ceil(time_remaining))
		if current_second != int(ceil(time_remaining + delta)):
			print("⏰ Battle Timer: ", current_second, " seconds remaining")
		
		# Time's up - Pokemon flees
		if time_remaining <= 0:
			timer_active = false
			pokemon_fled()
		
	if Input.is_action_just_pressed("ui_accept") and !is_menu_visible and !capture_in_progress and enemy.hp > 0:
		if is_dialog_finished:
			dialog.visible = false
			dialog_box.visible = false
			click_to_continue.visible = false
			anim.play("hide")
			menu.visible = true
			is_menu_visible = true
			attack_btn.grab_focus()
		else:
			dialog.visible_characters = dialog.text.length()

func on_enemy_dead():
	# No longer needed for capture system
	pass

func on_player_dead():
	# No longer needed for capture system  
	pass

func pokemon_fled():
	# Called when timer runs out
	print("💨 Pokemon fled! Time ran out!")
	capture_in_progress = true
	is_menu_visible = false
	menu.visible = false
	
	show_dialog(current_pokemon + " fled from battle!")
	
	# Send signal to React
	if JSBridge:
		JSBridge.send_message_to_react("POKEMON_FLED", {
			"pokemon_name": current_pokemon,
			"reason": "time_limit"
		})
	
	# Wait then exit battle
	await get_tree().create_timer(2.0).timeout
	anim.play("fade_out")

func start_battle_timer():
	# Start the countdown timer (hidden from player for added suspense)
	time_remaining = battle_timer
	timer_active = true
	
	print("⏰ Battle Timer Started: ", battle_timer, " seconds")
	
func move_menu_arrow(x,y):
	# position the arrow on the menu 
	menu_arrow.global_position.x = x
	menu_arrow.global_position.y = y

func show_dialog(custom_text):
	# show dialog box with custom text.
	GameManager.is_dialog = true
	dialog_box.visible = true
	menu.visible = false
	dialog.visible = true
	is_dialog_finished = false
	click_to_continue.visible = true
	text_timer.wait_time = text_speed
	anim.play("blink")
	next_text()
	dialog.text = str(custom_text)

func next_text() -> void:
	# animate the dialog text
	if text_num >= dialog.text.length():
		dialog.text = ""
		return
	
	is_dialog_finished = false
	
	dialog.visible_characters = 0
		
	while dialog.visible_characters < dialog.text.length():
		dialog.visible_characters += 1
		
		text_timer.start()
		await text_timer.timeout
	
	is_dialog_finished = true
	text_num += 1
	
	return

func _on_task_completed(completed: bool):
	# Called when React sends task completion result
	if completed:
		# Task solved correctly - trigger capture
		_trigger_capture()
	else:
		# Task failed - show message
		show_dialog("Task failed! Try again!")
		is_menu_visible = false
		# Allow player to try again
		await get_tree().create_timer(1.5).timeout
		menu.visible = true
		is_menu_visible = true
		attack_btn.grab_focus()

func _trigger_capture():
	# Triggered when task is completed successfully
	is_menu_visible = false
	capture_in_progress = true  # Prevent input during capture
	
	# Stop the timer
	timer_active = false
	
	print("✅ Pokemon captured with ", ceil(time_remaining), " seconds remaining!")
	
	# Calculate points based on level
	var enemy_level = enemy.current_pokemon_level
	var base_points = enemy_level * 100  # Level 1 = 100pts, Level 2 = 200pts, etc.
	
	# Calculate time bonus (percentage of time remaining)
	var time_percentage = (time_remaining / battle_timer) * 100.0
	var time_bonus = int(time_percentage)
	var total_points = base_points + time_bonus
	
	print("⏱️ Time Bonus: ", time_bonus, " points (", int(time_percentage), "% remaining)")
	print("💰 Total Points: ", total_points, " (Base: ", base_points, " + Bonus: ", time_bonus, ")")
	
	show_dialog("You captured " + current_pokemon + "! +" + str(total_points) + " points!")
	
	# Add to inventory using GameManager (local storage)
	GameManager.add_pokemon_to_inventory(current_pokemon, enemy_level, total_points)
	
	# Send capture data to React/Database
	if JSBridge:
		JSBridge.send_message_to_react("POKEMON_CAPTURED", {
			"pokemon_name": current_pokemon,
			"level": enemy_level,
			"points": total_points,
			"base_points": base_points,
			"time_bonus": time_bonus,
			"time_percentage": int(time_percentage),
			"captured_at": Time.get_datetime_string_from_system()
		})
	
	# Wait a moment then exit battle
	await get_tree().create_timer(2.0).timeout 
	anim.play("fade_out")

func _on_attack_btn_1_pressed():
	# Button now triggers task validation instead of instant capture
	is_menu_visible = false
	show_dialog("Solve the programming task to capture " + current_pokemon + "!")
	# React will handle showing the task and validating the solution

func _on_run_btn_pressed():
	# exit battle
	timer_active = false
	
	show_dialog("Run away safely")
	anim.play("fade_out")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		GameManager.is_battle = false
		# Send signal to React that battle has ended
		if JSBridge:
			JSBridge.send_message_to_react("BATTLE_ENDED", {"message": "battle ended"})
		queue_free()
		
	if anim_name == "fade_in":
		begin_battle = true
		# Start the battle timer
		start_battle_timer()
		# Send signal to React that battle has started and request a programming task
		if JSBridge:
			JSBridge.send_message_to_react("BATTLE_STARTED", {
				"message": "in battle",
				"pokemon_name": current_pokemon,
				"pokemon_level": enemy.current_pokemon_level
			})

func on_enemy_turn():
	# No longer needed for capture system
	pass

func on_player_animation_finished():
	# No longer needed for capture system
	pass

func on_enemy_animation_finished():
	# No longer needed for capture system
	pass
