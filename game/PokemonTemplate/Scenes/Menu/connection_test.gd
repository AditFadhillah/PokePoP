extends Control
# Database Connection Test Scene

@onready var test_button = $VBoxContainer/TestButton
@onready var health_button = $VBoxContainer/HealthButton
@onready var status_label = $VBoxContainer/StatusLabel
@onready var details_label = $VBoxContainer/DetailsLabel
@onready var back_button = $VBoxContainer/BackButton

func _ready():
	test_button.pressed.connect(_on_test_pressed)
	health_button.pressed.connect(_on_health_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect to Supabase signals
	if SupabaseManager:
		SupabaseManager.connection_tested.connect(_on_connection_result)
		SupabaseManager.error_occurred.connect(_on_error_occurred)
	
	# Show initial status
	update_status("Ready to test connection", "Click 'Test Connection' to check database connectivity")

func _on_test_pressed():
	test_button.disabled = true
	health_button.disabled = true
	update_status("Testing connection...", "Attempting to connect to Supabase database...")
	
	if SupabaseManager:
		SupabaseManager.test_connection()
	else:
		update_status("❌ Error", "SupabaseManager not found! Check autoload settings.")
		test_button.disabled = false
		health_button.disabled = false

func _on_health_pressed():
	test_button.disabled = true
	health_button.disabled = true
	update_status("Running health check...", "Checking server availability...")
	
	if SupabaseManager:
		SupabaseManager.health_check()
	else:
		update_status("❌ Error", "SupabaseManager not found! Check autoload settings.")
		test_button.disabled = false
		health_button.disabled = false

func _on_connection_result(success: bool, message: String):
	test_button.disabled = false
	health_button.disabled = false
	
	if success:
		update_status("✅ Connection Successful!", message)
		show_connection_details(true)
	else:
		update_status("❌ Connection Failed", message)
		show_connection_details(false)

func _on_error_occurred(message: String):
	test_button.disabled = false
	health_button.disabled = false
	update_status("❌ Error Occurred", message)
	show_connection_details(false)

func update_status(title: String, description: String):
	status_label.text = title
	details_label.text = description

func show_connection_details(success: bool):
	if success:
		var details = """
✅ Database Status: Connected
🔗 Supabase URL: %s
🔑 API Key: %s...
📊 Tables: Ready for use
🎮 Game Features: Enabled

Your Pokemon game can now:
• Save player data
• Track battle statistics  
• Store game progress
• Log battle history
		""" % [
			SupabaseManager.SUPABASE_URL if SupabaseManager else "Not configured",
			SupabaseManager.SUPABASE_ANON_KEY.substr(0, 20) if SupabaseManager else "Not configured"
		]
		details_label.text = details
	else:
		var details = """
❌ Connection Issues Detected

Troubleshooting steps:
1. Check your Supabase project is active
2. Verify SUPABASE_URL is correct
3. Verify SUPABASE_ANON_KEY is valid
4. Check your internet connection
5. Ensure Row Level Security policies are set

Current Configuration:
🔗 URL: %s
🔑 Key: %s
		""" % [
			SupabaseManager.SUPABASE_URL if SupabaseManager else "Not configured",
			SupabaseManager.SUPABASE_ANON_KEY.substr(0, 20) + "..." if SupabaseManager and SupabaseManager.SUPABASE_ANON_KEY.length() > 20 else "Not configured"
		]
		details_label.text = details

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")