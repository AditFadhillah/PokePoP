extends Node2D

@onready var world_music = $LittleRootTownMusic

func _ready():
	world_music.play()

func _process(delta):
	# control de music playing
	if GameManager.is_battle and world_music.is_playing():
		world_music.stop()
	
	if !GameManager.is_battle and !world_music.is_playing():
		world_music.play()
