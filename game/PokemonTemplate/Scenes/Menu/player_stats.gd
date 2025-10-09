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
	
	# Load and display player stats
	load_player_stats()
	
	# Connect to Supabase signals
	if SupabaseManager:
		SupabaseManager.player_data_loaded.connect(_on_player_data_loaded)

func load_player_stats():
	if not GameManager or not GameManager.current_player.has("id"):
		username_label.text = "No player data"
		return
	
	var player = GameManager.current_player
	display_player_stats(player)
	
	# Load recent battles
	if SupabaseManager:
		SupabaseManager.get_battle_history(player.id, 5)

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
	
	var last_played = player_data.get("last_played", "")
	if last_played:
		last_played_label.text = "Last Played: " + last_played.split("T")[0]
	else:
		last_played_label.text = "Last Played: Never"

func _on_player_data_loaded(player_data):
	if player_data:
		display_player_stats(player_data)
		# Update GameManager with fresh data
		if GameManager:
			GameManager.current_player = player_data

func _on_battles_loaded(battles_data):
	# Clear existing battle entries
	for child in recent_battles_list.get_children():
		child.queue_free()
	
	if not battles_data or battles_data.size() == 0:
		var no_battles = Label.new()
		no_battles.text = "No recent battles"
		recent_battles_list.add_child(no_battles)
		return
	
	# Add recent battle entries
	for battle in battles_data:
		var battle_entry = Label.new()
		var result_text = battle.battle_result.capitalize()
		var opponent = battle.opponent_pokemon
		var date = battle.created_at.split("T")[0]
		
		battle_entry.text = "%s vs %s - %s (%s)" % [battle.player_pokemon, opponent, result_text, date]
		recent_battles_list.add_child(battle_entry)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")