extends Control
# Player Statistics Screen

@onready var username_label = $VBoxContainer/UsernameLabel
@onready var battles_label = $VBoxContainer/BattlesLabel
@onready var wins_label = $VBoxContainer/WinsLabel
@onready var losses_label = $VBoxContainer/LossesLabel
@onready var win_rate_label = $VBoxContainer/WinRateLabel
@onready var last_played_label = $VBoxContainer/LastPlayedLabel
@onready var back_button = $VBoxContainer/BackButton
@onready var recent_battles_list = $VBoxContainer/ScrollContainer/RecentBattlesList

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	
	# Load and display local player stats
	load_player_stats()

func load_player_stats():
	# Display default/local stats
	var default_player = {
		"username": "Player",
		"total_battles": 0,
		"wins": 0,
		"losses": 0
	}
	display_player_stats(default_player)

func display_player_stats(player_data):
	username_label.text = "Player: " + player_data.get("username", "Unknown")
	battles_label.text = "Total Battles: " + str(player_data.get("total_battles", 0))
	wins_label.text = "Wins: " + str(player_data.get("wins", 0))
	losses_label.text = "Losses: " + str(player_data.get("losses", 0))
	
	var total = player_data.get("total_battles", 0)
	var wins = player_data.get("wins", 0)
	var win_rate = 0.0
	if total > 0:
		win_rate = (float(wins) / float(total)) * 100.0
	win_rate_label.text = "Win Rate: " + "%.1f" % win_rate + "%"
	
	last_played_label.text = "Last Played: Today"
	
	# Clear existing battle entries and show placeholder
	for child in recent_battles_list.get_children():
		child.queue_free()
	
	var no_battles = Label.new()
	no_battles.text = "No recent battles (local play only)"
	recent_battles_list.add_child(no_battles)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")