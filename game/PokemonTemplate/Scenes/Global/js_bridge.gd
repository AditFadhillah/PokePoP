extends Node
# JavaScript Bridge for communication with React app

signal enter_pressed_from_js
signal trainer_updated_from_js(trainer_name: String)
signal pokemon_inventory_updated_from_js(pokemon_data: Array)
signal capture_triggered_from_js(pokemon_data: Dictionary)

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
					trainer_name: event.data.trainer_name
				};
			}
		} else if (event.data && event.data.type === 'POKEMON_INVENTORY_UPDATE') {
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingInventoryUpdate = {
					pokemon_data: event.data.pokemon_data
				};
			}
		} else if (event.data && event.data.type === 'TRIGGER_CAPTURE') {
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingCapturetrigger = {
					pokemon_data: event.data.pokemon_data
				};
			}
		}
	});
	
	// Create bridge object for Godot to access
	window.godot_js_bridge = {
		pendingEnter: false,
		pendingTrainerUpdate: null,
		pendingInventoryUpdate: null,
		pendingCapturetrigger: null,
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
				if trainer_name != "":
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
					if pokemon_data.size() > 0:
						pokemon_inventory_updated_from_js.emit(pokemon_data)
	
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