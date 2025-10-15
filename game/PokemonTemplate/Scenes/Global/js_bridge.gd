extends Node
# JavaScript Bridge for communication with React app

signal enter_pressed_from_js

func _ready():
	# Only setup JavaScript bridge if running in web export
	if OS.get_name() == "Web":
		setup_js_bridge()

func setup_js_bridge():
	# Create JavaScript interface
	var js_code = """
	window.addEventListener('message', function(event) {
		if (event.data && event.data.type === 'PRESS_ENTER') {
			console.log('🎮 Received PRESS_ENTER message from React!');
			if (window.godot_js_bridge) {
				window.godot_js_bridge.pendingEnter = true;
			}
		}
	});
	
	// Create bridge object for Godot to access
	window.godot_js_bridge = {
		pendingEnter: false,
		sendMessageToReact: function(message) {
			// Send message to parent window (React app)
			window.parent.postMessage({
				type: 'GODOT_MESSAGE',
				data: message
			}, '*');
			console.log('📤 Sent message to React:', message);
		}
	};
	
	console.log('✅ JavaScript bridge initialized for Godot game!');
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
		""" % JSON.stringify(message)
		
		JavaScriptBridge.eval(js_send)
		print("📤 Sent message to React: ", message_type)

func _check_js_messages():
	# Check if JavaScript bridge has pending messages
	var js_check = """
	if (window.godot_js_bridge && window.godot_js_bridge.pendingEnter) {
		window.godot_js_bridge.pendingEnter = false;
		true;
	} else {
		false;
	}
	"""
	
	var result = JavaScriptBridge.eval(js_check)
	if result:
		print("🎮 Received ENTER signal from JavaScript!")
		enter_pressed_from_js.emit()
		# Simulate actual Enter key press
		simulate_enter_key()

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