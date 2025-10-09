extends Node2D

var turn = "player"
var is_battle = false
var is_dialog = false

# Player data from Supabase
var current_player = {}
var current_battle_start_time = 0
var current_opponent = ""
var current_player_pokemon = ""

func _ready():
	is_battle = false
	
	# Connect to battle signals
	if SignalManager:
		SignalManager.instantiate_battle.connect(_on_battle_started)
		SignalManager.enemy_dead.connect(_on_battle_won)
		SignalManager.player_dead.connect(_on_battle_lost)

func _on_battle_started():
	is_battle = true
	current_battle_start_time = Time.get_ticks_msec()

func _on_battle_won():
	_end_battle("win")

func _on_battle_lost():
	_end_battle("loss")

func _end_battle(result: String):
	if not is_battle:
		return
		
	is_battle = false
	var battle_duration = (Time.get_ticks_msec() - current_battle_start_time) / 1000
	
	# Log battle to database
	if SupabaseManager and current_player.has("id"):
		var exp_gained = 50 if result == "win" else 10
		SupabaseManager.log_battle(
			current_player.id,
			current_opponent,
			current_player_pokemon,
			result,
			battle_duration,
			exp_gained
		)
		
		# Update player battle stats
		SupabaseManager.update_player_battle_stats(current_player.id, result == "win")

func set_battle_participants(opponent: String, player_pokemon: String):
	current_opponent = opponent
	current_player_pokemon = player_pokemon

# Save game state to database
func save_game():
	if not SupabaseManager or not current_player.has("id"):
		return
	
	var game_data = {
		"current_scene": get_tree().current_scene.scene_file_path,
		"player_position": {}, # You'd add actual position data here
		"is_battle": is_battle,
		"is_dialog": is_dialog,
		"turn": turn
		# Add more game state data as needed
	}
	
	SupabaseManager.save_game_state(current_player.id, game_data)

# Auto-save every 30 seconds
var save_timer = 0.0
const AUTO_SAVE_INTERVAL = 30.0

func _process(delta):
	save_timer += delta
	if save_timer >= AUTO_SAVE_INTERVAL:
		save_timer = 0.0
		save_game()
