extends Control

@onready var message_label = $CanvasLayer/UI/MessageLabel
@onready var anim = $CanvasLayer/AnimationPlayer

var message_text: String = ""

func _ready():
	# Show welcome message with fade in
	anim.play("fade_in")
	message_label.text = message_text
	
	# Auto-close after 2 seconds (longer for welcome message)
	await get_tree().create_timer(2.0).timeout
	close_message()

func set_message(text: String):
	message_text = text
	if message_label:
		message_label.text = message_text

func _process(_delta):
	pass

func close_message():
	anim.play("fade_out")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		queue_free()
