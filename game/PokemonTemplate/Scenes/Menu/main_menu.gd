extends Control

func _ready():
	$Music.play()
	
	# Connect to JavaScript bridge signal
	if JSBridge:
		JSBridge.enter_pressed_from_js.connect(_on_js_enter_pressed)

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
