extends Node2D

var turn = "player"
var is_battle = false
var is_dialog = false

# Local player data
var current_player = {
	"username": "Player",
	"total_battles": 0,
	"wins": 0,
	"losses": 0
}
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
	
	# Update local stats
	current_player.total_battles += 1
	if result == "win":
		current_player.wins += 1
	else:
		current_player.losses += 1
	
	print("Battle ended: ", result, " (Duration: ", battle_duration, "s)")
	print("Updated stats - Battles: ", current_player.total_battles, ", Wins: ", current_player.wins, ", Losses: ", current_player.losses)

func set_battle_participants(opponent: String, player_pokemon: String):
	current_opponent = opponent
	current_player_pokemon = player_pokemon

# Save game state locally (could be extended to save to file)
func save_game():
	print("Game saved locally")
	# Could implement local file saving here if needed

# Auto-save every 30 seconds (disabled for local play)
var save_timer = 0.0
const AUTO_SAVE_INTERVAL = 30.0

func _process(delta):
	# Auto-save disabled for local play
	pass
		save_game()
