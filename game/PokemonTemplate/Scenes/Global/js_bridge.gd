extends Node
# JavaScript Bridge for communication with React app

signal enter_pressed_from_js
signal trainer_updated_from_js(trainer_name: String)

func _ready():
	print("JSBridge: _ready() called")
	# Only setup JavaScript bridge if running in web export
	if OS.get_name() == "Web":
		print("JSBridge: Running in web, setting up bridge")
		
		# Test if we're in an iframe
		var test_iframe = """
		console.log('Checking if running in iframe...');
		console.log('window.parent === window:', window.parent === window);
		console.log('window.top === window:', window.top === window);
		if (window.parent !== window) {
			console.log('Running in iframe - React communication possible');
		} else {
			console.log('Running standalone - React communication NOT possible');
		}
		"""
		JavaScriptBridge.eval(test_iframe)
		
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
			console.log('Received PRESS_ENTER message from React');
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
		}
	});
	
	// Create bridge object for Godot to access
	window.godot_js_bridge = {
		pendingEnter: false,
		pendingTrainerUpdate: null,
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
	
	console.log('Javascript bridge initialized for Godot game');
	"""
	
	JavaScriptBridge.eval(js_code)
	print("JSBridge: JavaScript code evaluated")
	
	# Setup periodic check for Javascript messages
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
		
		var js_send = """
		console.log('Godot: Attempting to send message to React');
		if (window.godot_js_bridge && window.godot_js_bridge.sendMessageToReact) {
			window.godot_js_bridge.sendMessageToReact(%s);
			console.log('Godot: Message sent successfully');
		} else {
			console.error('Godot: Bridge not available');
		}
		""" % JSON.stringify(message)
		
		JavaScriptBridge.eval(js_send)
		print("Sent message to React: ", message_type)
	else:
		print("JSBridge: Not in web environment, cannot send message")

func _check_js_messages():
	# Check if JavaScript bridge has pending messages
	var js_check = """
	(function() {
		if (window.godot_js_bridge) {
			var result = {
				enter: false,
				trainer: null
			};
			
			if (window.godot_js_bridge.pendingEnter) {
				window.godot_js_bridge.pendingEnter = false;
				result.enter = true;
			}
			
			if (window.godot_js_bridge.pendingTrainerUpdate) {
				result.trainer = window.godot_js_bridge.pendingTrainerUpdate;
				window.godot_js_bridge.pendingTrainerUpdate = null;
			}
			
			return result;
		}
		return { enter: false, trainer: null };
	})();
	"""
	
	var result = JavaScriptBridge.eval(js_check)
	
	if result && typeof(result) == TYPE_DICTIONARY:
		# Handle enter key press
		if result.get("enter", false):
			print("Received ENTER signal from Javascript")
			enter_pressed_from_js.emit()
			simulate_enter_key()
		
		# Handle trainer update
		var trainer_data = result.get("trainer", null)
		if trainer_data && typeof(trainer_data) == TYPE_DICTIONARY:
			var trainer_name = trainer_data.get("trainer_name", "")
			if trainer_name != "":
				print("Received trainer update from Javascript:", trainer_name)
				trainer_updated_from_js.emit(trainer_name)

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
	
	print("Simulated ENTER key press in Godot")