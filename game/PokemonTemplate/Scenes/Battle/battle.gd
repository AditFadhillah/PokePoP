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

# Random Pokemon encounter system
var pokemon_pool = ["BULBASAUR", "CATERPIE", "EEVEE", "PIDGEY", "VULPIX", "RATTATA"]
var current_pokemon = ""

func _ready():
	SignalManager.connect("btn_pos", move_menu_arrow)
	SignalManager.connect("player_animation_finished", on_player_animation_finished)
	SignalManager.connect("enemy_animation_finished", on_enemy_animation_finished)
	SignalManager.connect("enemy_dead", on_enemy_dead)
	SignalManager.connect("player_dead", on_player_dead)
	
	# Select random Pokemon for this battle
	current_pokemon = pokemon_pool[randi() % pokemon_pool.size()]

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

func _process(_delta):
	click_to_continue.visible = is_dialog_finished
	
	if begin_battle:
		show_dialog("A wild " + current_pokemon + " appeared!")
		begin_battle = false
		
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

func _on_attack_btn_1_pressed():
	# Attack instantly defeats/captures the Pokémon
	is_menu_visible = false
	capture_in_progress = true  # Prevent input during capture
	show_dialog("You captured " + current_pokemon + "!")
	
	# Calculate points based on level
	var enemy_level = enemy.current_pokemon_level
	var points = enemy_level * 100  # Level 1 = 100pts, Level 2 = 200pts, etc.
	
	# Add to inventory using GameManager (local storage)
	GameManager.add_pokemon_to_inventory(current_pokemon, enemy_level, points)
	
	# Send capture data to React/Database
	if JSBridge:
		JSBridge.send_message_to_react("POKEMON_CAPTURED", {
			"pokemon_name": current_pokemon,
			"level": enemy_level,
			"points": points,
			"captured_at": Time.get_datetime_string_from_system()
		})
	
	# Wait a moment then exit battle
	await get_tree().create_timer(2.0).timeout 
	anim.play("fade_out")

func _on_run_btn_pressed():
	# exit battle
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
		# Send signal to React that battle has started
		if JSBridge:
			JSBridge.send_message_to_react("BATTLE_STARTED", {"message": "in battle"})

func on_enemy_turn():
	# No longer needed for capture system
	pass

func on_player_animation_finished():
	# No longer needed for capture system
	pass

func on_enemy_animation_finished():
	# No longer needed for capture system
	pass
