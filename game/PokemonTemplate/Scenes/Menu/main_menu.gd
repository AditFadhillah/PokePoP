extends Control

func _ready():
	$Music.play()
	
	# Connect to JavaScript bridge signals
	if JSBridge:
		JSBridge.enter_pressed_from_js.connect(_on_js_enter_pressed)
		JSBridge.mute_audio_from_js.connect(_on_mute_audio_from_js)

func _process(delta):
	if Input.is_action_pressed("start"):
		# Notify React that ENTER was pressed
		if JSBridge:
			JSBridge.notify_enter_pressed()
		load_game()

func _on_js_enter_pressed():
	print("🌐 Main Menu: Received ENTER from JavaScript bridge!")
	# Notify React that ENTER was pressed
	if JSBridge:
		JSBridge.notify_enter_pressed()
	load_game()

func load_game():
	get_tree().change_scene_to_file("res://Scenes/Levels/world.tscn")

func _on_mute_audio_from_js(mute: bool):
	if mute:
		$Music.stream_paused = true
	else:
		$Music.stream_paused = false
