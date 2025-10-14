extends Control

@onready var player_name_label = $VBoxContainer/PlayerNameLabel

func _ready():
	$Music.play()
	
	# Display default player info
	player_name_label.text = "Welcome, Player"

func _process(delta):
	if Input.is_action_pressed("start"):
		load_game()

func load_game():
	get_tree().change_scene_to_file("res://Scenes/Levels/world.tscn")

func _on_stats_button_pressed():
	# Show player stats scene
	get_tree().change_scene_to_file("res://Scenes/Menu/player_stats.tscn")
