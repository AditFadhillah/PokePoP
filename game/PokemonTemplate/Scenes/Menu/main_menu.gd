extends Control

@onready var player_name_label = $VBoxContainer/PlayerNameLabel

func _ready():
	$Music.play()
	
	# Display current player info
	if GameManager and GameManager.current_player.has("username"):
		player_name_label.text = "Welcome, " + GameManager.current_player.username
		
		# Load player stats
		if SupabaseManager and GameManager.current_player.has("id"):
			SupabaseManager.get_player(GameManager.current_player.username)

func _process(delta):
	if Input.is_action_pressed("start"):
		load_game()

func load_game():
	get_tree().change_scene_to_file("res://Scenes/Levels/world.tscn")

func _on_stats_button_pressed():
	# Show player stats scene
	get_tree().change_scene_to_file("res://Scenes/Menu/player_stats.tscn")

func _on_test_connection_button_pressed():
	# Show connection test scene
	get_tree().change_scene_to_file("res://Scenes/Menu/connection_test.tscn")

func _on_logout_button_pressed():
	# Clear player data and return to login
	if GameManager:
		GameManager.current_player = {}
	if SupabaseManager:
		SupabaseManager.current_player_id = ""
	get_tree().change_scene_to_file("res://Scenes/Menu/login_screen.tscn")
