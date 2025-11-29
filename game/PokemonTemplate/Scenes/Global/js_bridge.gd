extends Node
# JavaScript Bridge for communication with React app

signal enter_pressed_from_js
signal trainer_updated_from_js(trainer_name: String)
signal pokemon_inventory_updated_from_js(pokemon_data: Array, total_points: int)
signal capture_triggered_from_js(pokemon_data: Dictionary)
signal task_completed_from_js(task_completed: bool)
signal mute_audio_from_js(mute: bool)

func _ready():
	# Only setup JavaScript bridge if running in web export
	if OS.get_name() == "Web":
		setup_js_bridge()

func setup_js_bridge():
	# Create JavaScript interface
	var js_code = """
	console.log('Godot JSBridge initialized');
	window.addEventListener('message', function(event) {
		if (event.data && event.data.type === 'PRESS_ENTER') {
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingEnter = true;
			}
		} else if (event.data && event.data.type === 'TRAINER_SELECTED') {
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingTrainerUpdate = {
					trainer_name: event.data.trainer_name,
					total_points: event.data.total_points || 0
				};
			}
		} else if (event.data && event.data.type === 'POKEMON_INVENTORY_UPDATE') {
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingInventoryUpdate = {
					pokemon_data: event.data.pokemon_data,
					total_points: event.data.total_points || 0
				};
			}
		} else if (event.data && event.data.type === 'TRIGGER_CAPTURE') {
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingCapturetrigger = {
					pokemon_data: event.data.pokemon_data
				};
			}
		} else if (event.data && event.data.type === 'TASK_COMPLETED') {
			console.log('JS Bridge received TASK_COMPLETED:', event.data);
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingTaskCompletion = {
					completed: event.data.completed,
					task_id: event.data.task_id
				};
				console.log('Stored in pendingTaskCompletion:', window.godot_js_bridge.pendingTaskCompletion);
			}
		} else if (event.data && event.data.type === 'MUTE_AUDIO') {
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingMute = true;
			}
		} else if (event.data && event.data.type === 'UNMUTE_AUDIO') {
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingMute = false;
			}
		}
	});
	
	// Create bridge object for Godot to access
	window.godot_js_bridge = {
		pendingEnter: false,
		pendingTrainerUpdate: null,
		pendingInventoryUpdate: null,
		pendingCapturetrigger: null,
		pendingTaskCompletion: null,
		pendingMute: undefined,
		sendMessageToReact: function(message) {
			window.parent.postMessage({
				type: 'GODOT_MESSAGE',
				data: message
			}, '*');
		}
	};
	"""
	
	JavaScriptBridge.eval(js_code)
	
	# Setup periodic check for JavaScript messages
	var timer = Timer.new()
	timer.wait_time = 0.1  # Check every 100ms
	timer.timeout.connect(_check_js_messages)
	add_child(timer)
	timer.start()

# Function to send messages from Godot to React
func send_message_to_react(message_type: String, data: Dictionary = {}):
	if OS.get_name() == "Web":
		var message = {
			"type": message_type,
			"data": data,
			"timestamp": Time.get_ticks_msec()
		}
		
		var js_send = """
		if (window.godot_js_bridge && window.godot_js_bridge.sendMessageToReact) {
			window.godot_js_bridge.sendMessageToReact(%s);
		}
		""" % [JSON.stringify(message)]
		
		JavaScriptBridge.eval(js_send)

func _check_js_messages():
	# Debug: Show that this function is being called
	# print("JSBridge: _check_js_messages() called")  # Disabled to reduce noise
	
	# Check for ENTER messages (simplified version that works)
	var enter_check = """
	if (window.godot_js_bridge && window.godot_js_bridge.pendingEnter) {
		window.godot_js_bridge.pendingEnter = false;
		true;
	} else {
		false;
	}
	"""
	
	var enter_result = JavaScriptBridge.eval(enter_check)
	if enter_result:
		enter_pressed_from_js.emit()
		simulate_enter_key()
	
	# Check for trainer updates
	var trainer_check = """
	if (window.godot_js_bridge && window.godot_js_bridge.pendingTrainerUpdate) {
		var trainer = window.godot_js_bridge.pendingTrainerUpdate;
		window.godot_js_bridge.pendingTrainerUpdate = null;
		JSON.stringify(trainer);
	} else {
		null;
	}
	"""
	
	var trainer_json = JavaScriptBridge.eval(trainer_check)
	
	if trainer_json != null and typeof(trainer_json) == TYPE_STRING:
		var json = JSON.new()
		var parse_result = json.parse(trainer_json)
		
		if parse_result == OK:
			var trainer_result = json.data
			
			if typeof(trainer_result) == TYPE_DICTIONARY:
				var trainer_name = trainer_result.get("trainer_name", "")
				var total_points = trainer_result.get("total_points", 0)
				print("👤 Trainer update received - Name: ", trainer_name, " Total points from DB: ", total_points)
				if trainer_name != "":
					# Store the total_points in GameManager
					if total_points > 0:
						GameManager.set_total_points_override(total_points)
					else:
						print("⚠️ Warning: total_points is 0 or not provided in trainer update!")
					trainer_updated_from_js.emit(trainer_name)
	
	# Check for inventory updates
	var has_inventory = JavaScriptBridge.eval("""
		window.godot_js_bridge && window.godot_js_bridge.pendingInventoryUpdate ? true : false;
	""")
	
	if has_inventory:
		var inventory_json = JavaScriptBridge.eval("""
			(function() {
				if (window.godot_js_bridge && window.godot_js_bridge.pendingInventoryUpdate) {
					var inventory = window.godot_js_bridge.pendingInventoryUpdate;
					window.godot_js_bridge.pendingInventoryUpdate = null;
					return JSON.stringify(inventory);
				}
				return null;
			})();
		""")
		
		if inventory_json and typeof(inventory_json) == TYPE_STRING:
			var json = JSON.new()
			var parse_result = json.parse(inventory_json)
			
			if parse_result == OK:
				var inventory_result = json.data
				if typeof(inventory_result) == TYPE_DICTIONARY:
					var pokemon_data = inventory_result.get("pokemon_data", [])
					var total_points = inventory_result.get("total_points", 0)
					print("📦 Inventory update received - Pokemon count: ", pokemon_data.size(), " Total points from DB: ", total_points)
					if pokemon_data.size() > 0:
						# Emit with total_points so it can be used immediately
						pokemon_inventory_updated_from_js.emit(pokemon_data, total_points)
	
	# Check for capture triggers
	var capture_check = """
	if (window.godot_js_bridge && window.godot_js_bridge.pendingCapturetrigger) {
		var capture = window.godot_js_bridge.pendingCapturetrigger;
		window.godot_js_bridge.pendingCapturetrigger = null;
		capture;
	} else {
		null;
	}
	"""
	
	var capture_result = JavaScriptBridge.eval(capture_check)
	if capture_result && typeof(capture_result) == TYPE_DICTIONARY:
		var pokemon_data = capture_result.get("pokemon_data", {})
		if pokemon_data.size() > 0:
			capture_triggered_from_js.emit(pokemon_data)
	
	# Check for task completion
	var task_check = """
	(function() {
		if (window.godot_js_bridge && window.godot_js_bridge.pendingTaskCompletion) {
			var task = window.godot_js_bridge.pendingTaskCompletion;
			window.godot_js_bridge.pendingTaskCompletion = null;
			return JSON.stringify(task);
		}
		return null;
	})();
	"""
	
	var task_json = JavaScriptBridge.eval(task_check)
	
	if task_json != null && typeof(task_json) == TYPE_STRING:
		print("✅ Received task JSON: ", task_json)
		var json = JSON.new()
		var parse_result = json.parse(task_json)
		
		if parse_result == OK:
			var task_data = json.data
			if typeof(task_data) == TYPE_DICTIONARY:
				var completed = task_data.get("completed", false)
				print("✅ Task completion received from JS: ", completed)
				task_completed_from_js.emit(completed)
	
	# Check for mute/unmute
	var mute_check = """
	if (window.godot_js_bridge && typeof window.godot_js_bridge.pendingMute !== 'undefined') {
		var mute = window.godot_js_bridge.pendingMute;
		window.godot_js_bridge.pendingMute = undefined;
		mute;
	} else {
		null;
	}
	"""
	
	var mute_result = JavaScriptBridge.eval(mute_check)
	if mute_result != null:
		print("🔇 Mute signal received: ", mute_result)
		# Update global mute state
		GameManager.set_muted(mute_result)
		mute_audio_from_js.emit(mute_result)

func simulate_enter_key():
	# Create an input event for Enter key
	var input_event = InputEventKey.new()
	input_event.keycode = KEY_ENTER
	input_event.pressed = true
	
	# Send the input event
	Input.parse_input_event(input_event)
	
	# Send key release
	await get_tree().create_timer(0.1).timeout
	input_event.pressed = false
	Input.parse_input_event(input_event)

# Call this function from your game's main script when ENTER is pressed during gameplay
func notify_enter_pressed():
	# Send signal to React that ENTER was pressed in game
	send_message_to_react("ENTER_PRESSED_IN_GAME", {})
	print("Sent ENTER_PRESSED_IN_GAME signal to React")