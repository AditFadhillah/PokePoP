extends Node
# JavaScript Bridge for communication with React app

signal enter_pressed_from_js
signal trainer_updated_from_js(trainer_name: String)
signal pokemon_inventory_updated_from_js(pokemon_data: Array)
signal capture_triggered_from_js(pokemon_data: Dictionary)
signal test_pokemon_signal(pokemon_text: String)

func _ready():
	print("JSBridge: _ready() called")
	# Only setup JavaScript bridge if running in web export
	if OS.get_name() == "Web":
		print("JSBridge: Running in web, setting up bridge")
		setup_js_bridge()
	else:
		print("JSBridge: Not running in web, OS: ", OS.get_name())

func setup_js_bridge():
	print("JSBridge: Setting up JavaScript bridge")
	# Create JavaScript interface
	var js_code = """
	console.log('Godot JSBridge: Starting setup');
	window.addEventListener('message', function(event) {
		console.log('Godot received message:', event.data);
		if (event.data && event.data.type === 'PRESS_ENTER') {
			console.log('Received PRESS_ENTER message from React!');
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingEnter = true;
			}
		} else if (event.data && event.data.type === 'TRAINER_SELECTED') {
			console.log('Received TRAINER_SELECTED message from React:', event.data);
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingTrainerUpdate = {
					trainer_name: event.data.trainer_name
				};
			}
		} else if (event.data && event.data.type === 'POKEMON_INVENTORY_UPDATE') {
			console.log('Received POKEMON_INVENTORY_UPDATE message from React:', event.data);
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingInventoryUpdate = {
					pokemon_data: event.data.pokemon_data
				};
			}
		} else if (event.data && event.data.type === 'TRIGGER_CAPTURE') {
			console.log('Received TRIGGER_CAPTURE message from React:', event.data);
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingCapturetrigger = {
					pokemon_data: event.data.pokemon_data
				};
			}
		} else if (event.data && event.data.type === 'TEST_POKEMON') {
			console.log('Received TEST_POKEMON message from React:', event.data);
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingTestPokemon = event.data.pokemon_text || 'CATERPIE';
			}
		}
	});
	
	// Create bridge object for Godot to access
	window.godot_js_bridge = {
		pendingEnter: false,
		pendingTrainerUpdate: null,
		pendingInventoryUpdate: null,
		pendingCapturetrigger: null,
		pendingTestPokemon: null,
		sendMessageToReact: function(message) {
			// Send message to parent window (React app)
			console.log('Godot sending message to React:', message);
			window.parent.postMessage({
				type: 'GODOT_MESSAGE',
				data: message
			}, '*');
			console.log('Sent message to React:', message);
		}
	};
	
	console.log('✅ JavaScript bridge initialized for Godot game!');
	"""
	
	JavaScriptBridge.eval(js_code)
	print("JSBridge: JavaScript code evaluated")
	
	# Setup periodic check for JavaScript messages
	var timer = Timer.new()
	timer.wait_time = 0.1  # Check every 100ms
	timer.timeout.connect(_check_js_messages)
	add_child(timer)
	timer.start()
	print("JSBridge: Timer started for message checking")

# Function to send messages from Godot to React
func send_message_to_react(message_type: String, data: Dictionary = {}):
	print("JSBridge: send_message_to_react called with type: ", message_type)
	if OS.get_name() == "Web":
		var message = {
			"type": message_type,
			"data": data,
			"timestamp": Time.get_ticks_msec()
		}
		
		print("JSBridge: Preparing to send message: ", message)
		
		var js_send = """
		console.log('Godot: Attempting to send message to React');
		console.log('Message details:', %s);
		if (window.godot_js_bridge && window.godot_js_bridge.sendMessageToReact) {
			window.godot_js_bridge.sendMessageToReact(%s);
			console.log('Godot: Message sent successfully');
		} else {
			console.error('Godot: Bridge not available');
			console.log('Bridge state:', window.godot_js_bridge);
		}
		""" % [JSON.stringify(message), JSON.stringify(message)]
		
		JavaScriptBridge.eval(js_send)
		print("Sent message to React: ", message_type)
	else:
		print("JSBridge: Not in web environment, cannot send message")

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
		print("🎮 Received ENTER signal from JavaScript!")
		enter_pressed_from_js.emit()
		simulate_enter_key()
	
	# Check for trainer updates (keep this separate)
	var trainer_check = """
	if (window.godot_js_bridge && window.godot_js_bridge.pendingTrainerUpdate) {
		var trainer = window.godot_js_bridge.pendingTrainerUpdate;
		window.godot_js_bridge.pendingTrainerUpdate = null;
		trainer;
	} else {
		null;
	}
	"""
	
	var trainer_result = JavaScriptBridge.eval(trainer_check)
	if trainer_result && typeof(trainer_result) == TYPE_DICTIONARY:
		var trainer_name = trainer_result.get("trainer_name", "")
		if trainer_name != "":
			print("Received trainer update from Javascript:", trainer_name)
			trainer_updated_from_js.emit(trainer_name)
	
	# Check for inventory updates (keep this separate)
	var inventory_check = """
	if (window.godot_js_bridge && window.godot_js_bridge.pendingInventoryUpdate) {
		var inventory = window.godot_js_bridge.pendingInventoryUpdate;
		window.godot_js_bridge.pendingInventoryUpdate = null;
		inventory;
	} else {
		null;
	}
	"""
	
	var inventory_result = JavaScriptBridge.eval(inventory_check)
	if inventory_result && typeof(inventory_result) == TYPE_DICTIONARY:
		var pokemon_data = inventory_result.get("pokemon_data", [])
		if pokemon_data.size() > 0:
			print("Received Pokemon inventory update from Javascript:", pokemon_data.size(), " Pokemon")
			pokemon_inventory_updated_from_js.emit(pokemon_data)
	
	# Check for capture triggers (keep this separate)
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
	if capture_result:
		print("🎯 JSBridge: JavaScriptBridge.eval returned:", typeof(capture_result), " - ", capture_result)
		if typeof(capture_result) == TYPE_DICTIONARY:
			var pokemon_data = capture_result.get("pokemon_data", {})
			if pokemon_data.size() > 0:
				print("🎯 JSBridge: Emitting capture_triggered_from_js signal with:", pokemon_data)
				capture_triggered_from_js.emit(pokemon_data)
			else:
				print("🚨 JSBridge: pokemon_data is empty:", pokemon_data)
		else:
			print("🚨 JSBridge: capture_result is not dictionary, type:", typeof(capture_result))
	else:
		# Uncomment this line temporarily to debug if eval is returning null
		# print("🔍 JSBridge: No capture trigger pending (eval returned null)")
		pass
	
	# Check for TEST_POKEMON signal (now returns text instead of boolean)
	var test_pokemon_check = """
	if (window.godot_js_bridge && window.godot_js_bridge.pendingTestPokemon) {
		var text = window.godot_js_bridge.pendingTestPokemon;
		window.godot_js_bridge.pendingTestPokemon = null;
		text;
	} else {
		null;
	}
	"""
	
	var test_result = JavaScriptBridge.eval(test_pokemon_check)
	if test_result && typeof(test_result) == TYPE_STRING:
		print("🧪 JSBridge: TEST_POKEMON signal received with text: '", test_result, "'")
		test_pokemon_signal.emit(test_result)

func simulate_enter_key():
	# Create an input event for Enter key
	var input_event = InputEventKey.new()
	input_event.keycode = KEY_ENTER
	input_event.pressed = true
	
	# Send the input event to the main scene
	Input.parse_input_event(input_event)
	
	# Also send key release
	await get_tree().create_timer(0.1).timeout
	input_event.pressed = false
	Input.parse_input_event(input_event)
	
	print("✅ Simulated ENTER key press in Godot!")