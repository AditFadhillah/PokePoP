extends Node
# Supabase Database Manager for Godot
# This script handles all database operations with Supabase

# Supabase configuration - REPLACE WITH YOUR ACTUAL VALUES
const SUPABASE_URL = "https://ajkcuijxkwiwmbxokexb.supabase.co"  # e.g., "https://your-project.supabase.co"
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFqa2N1aWp4a3dpd21ieG9rZXhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3NjE2NDMsImV4cCI6MjA3NDMzNzY0M30.dnDri0J7mUCSL5pWHbsY-TgfH73yqeWTQ8loST78hnM"  # Your public anon key

var http_request: HTTPRequest
var current_player_id: String = ""

signal player_data_loaded(player_data)
signal battle_logged(success)
signal pokemon_caught(success)
signal save_game_completed(success)
signal error_occurred(message)
signal connection_tested(success, message)

func _ready():
	# Create HTTP request node
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# Auto-test connection on startup
	print("🚀 SupabaseManager initialized")
	await get_tree().create_timer(1.0).timeout  # Wait a moment for everything to load
	health_check()

var pending_requests = {}
var request_counter = 0

# Generic function to make HTTP requests to Supabase
func make_supabase_request(method: String, endpoint: String, data = null, callback_signal: String = ""):
	if SUPABASE_URL == "YOUR_SUPABASE_URL_HERE":
		push_error("Please configure your Supabase URL and API key in SupabaseManager")
		return false
	
	var url = SUPABASE_URL + "/rest/v1/" + endpoint
	var headers = [
		"apikey: " + SUPABASE_ANON_KEY,
		"Authorization: Bearer " + SUPABASE_ANON_KEY,
		"Content-Type: application/json",
		"Prefer: return=representation"
	]
	
	var json_data = ""
	if data != null:
		json_data = JSON.stringify(data)
	
	# Store request info for callback
	request_counter += 1
	pending_requests[request_counter] = {
		"signal": callback_signal,
		"endpoint": endpoint
	}
	
	match method.to_upper():
		"GET":
			return http_request.request(url, headers)
		"POST":
			return http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
		"PATCH":
			return http_request.request(url, headers, HTTPClient.METHOD_PATCH, json_data)
		"DELETE":
			return http_request.request(url, headers, HTTPClient.METHOD_DELETE)
	
	return false

# Create or get player
func create_player(username: String):
	var data = {
		"username": username,
		"created_at": Time.get_datetime_string_from_system(),
		"last_played": Time.get_datetime_string_from_system()
	}
	make_supabase_request("POST", "players", data, "player_created")

# Get player by username
func get_player(username: String):
	make_supabase_request("GET", "players?username=eq." + username, null, "player_loaded")

# Update player stats after battle
func update_player_battle_stats(player_id: String, won: bool):
	var data = {
		"total_battles": "total_battles + 1",
		"last_played": Time.get_datetime_string_from_system()
	}
	
	if won:
		data["wins"] = "wins + 1"
	else:
		data["losses"] = "losses + 1"
	
	make_supabase_request("PATCH", "players?id=eq." + player_id, data, "player_updated")

# Log a battle
func log_battle(player_id: String, opponent_pokemon: String, player_pokemon: String, result: String, duration: int = 0, exp_gained: int = 0):
	var data = {
		"player_id": player_id,
		"opponent_pokemon": opponent_pokemon,
		"player_pokemon": player_pokemon,
		"battle_result": result,
		"battle_duration": duration,
		"experience_gained": exp_gained
	}
	make_supabase_request("POST", "battle_logs", data, "battle_logged")

# Save pokemon stats when caught
func save_pokemon(player_id: String, pokemon_name: String, pokemon_id: int, level: int, hp: int, max_hp: int, attack: int, defense: int, speed: int):
	var data = {
		"player_id": player_id,
		"pokemon_name": pokemon_name,
		"pokemon_id": pokemon_id,
		"level": level,
		"hp": hp,
		"max_hp": max_hp,
		"attack": attack,
		"defense": defense,
		"speed": speed
	}
	make_supabase_request("POST", "pokemon_stats", data, "pokemon_saved")

# Save game state
func save_game_state(player_id: String, game_data: Dictionary, save_name: String = "Auto Save"):
	var data = {
		"player_id": player_id,
		"save_data": game_data,
		"save_name": save_name,
		"updated_at": Time.get_datetime_string_from_system()
	}
	make_supabase_request("POST", "game_saves", data, "game_saved")

# Load game state
func load_game_state(player_id: String):
	make_supabase_request("GET", "game_saves?player_id=eq." + player_id + "&order=updated_at.desc&limit=1", null, "game_loaded")

# Get player's pokemon
func get_player_pokemon(player_id: String):
	make_supabase_request("GET", "pokemon_stats?player_id=eq." + player_id, null, "pokemon_loaded")

# Get battle history
func get_battle_history(player_id: String, limit: int = 10):
	make_supabase_request("GET", "battle_logs?player_id=eq." + player_id + "&order=created_at.desc&limit=" + str(limit), null, "battles_loaded")

# Test database connection
func test_connection():
	print("🔍 Testing Supabase connection...")
	make_supabase_request("GET", "players?limit=1", null, "connection_test")

# Simple health check
func health_check():
	print("🏥 Running Supabase health check...")
	if SUPABASE_URL == "YOUR_SUPABASE_URL_HERE" or SUPABASE_ANON_KEY == "YOUR_ANON_KEY_HERE":
		emit_signal("connection_tested", false, "❌ Supabase credentials not configured")
		return
	
	var url = SUPABASE_URL + "/rest/v1/"
	var headers = [
		"apikey: " + SUPABASE_ANON_KEY,
		"Authorization: Bearer " + SUPABASE_ANON_KEY
	]
	
	var request_id = request_counter + 1
	pending_requests[request_id] = {
		"signal": "health_check",
		"type": "health"
	}
	
	http_request.request(url, headers)

# Handle HTTP request responses
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var response_text = body.get_string_from_utf8()
	
	# Check for successful response
	if response_code >= 200 and response_code < 300:
		var json = JSON.new()
		var parse_result = json.parse(response_text)
		
		if parse_result == OK:
			var data = json.data
			_handle_success_response(data, response_code)
		else:
			print("❌ Failed to parse JSON response")
			emit_signal("error_occurred", "Failed to parse JSON response")
			emit_signal("connection_tested", false, "Invalid JSON response from server")
	else:
		var error_msg = "HTTP Error " + str(response_code)
		if response_text:
			error_msg += ": " + response_text
		print("❌ ", error_msg)
		emit_signal("error_occurred", error_msg)
		emit_signal("connection_tested", false, error_msg)

func _handle_success_response(data, response_code = 200):
	# Handle connection test specifically
	if request_counter > 0 and pending_requests.has(request_counter):
		var request_info = pending_requests[request_counter]
		if request_info.get("signal", "") == "connection_test":
			print("✅ Supabase connection successful!")
			print("   Response code: ", response_code)
			print("   Database accessible: ", data is Array)
			emit_signal("connection_tested", true, "Connection successful! Database is accessible.")
			pending_requests.erase(request_counter)
			return
		elif request_info.get("type", "") == "health":
			print("✅ Supabase health check passed!")
			print("   Server responding: ", response_code == 200)
			emit_signal("connection_tested", true, "Health check passed! Server is responding.")
			pending_requests.erase(request_counter)
			return
	
	# This is where you'd handle different types of responses
	# For now, we'll emit general success signals
	print("✅ Supabase operation successful: ", data)
	
	# You can add more specific handling based on the request type
	if data is Array and data.size() > 0:
		var first_record = data[0]
		if first_record.has("username"):
			emit_signal("player_data_loaded", first_record)
	
	# For other operations, you might want to emit specific signals
	# This is a simplified version - you'd want to match the response to the original request

# Utility function to generate a simple UUID (for offline use)
func generate_simple_uuid() -> String:
	var uuid = ""
	for i in range(32):
		if i in [8, 12, 16, 20]:
			uuid += "-"
		uuid += "%x" % (randi() % 16)
	return uuid