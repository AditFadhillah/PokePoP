extends CharacterBody2D

# player variables
@export var speed = 40
@export var max_speed = 100
@export var FRICTION: float = 0.15
var is_alive = true
var move_direction = Vector2.ZERO

# tile data
var is_on_tall_grass
var current_tile: Vector2i
@onready var tiles_node = get_tree().current_scene.get_node("Tiles")
@onready var tall_grass_layer: TileMapLayer

# battle variables
var rng = RandomNumberGenerator.new()
var random_encounter
var battle_scene = preload("res://Scenes/Battle/battle.tscn")
var probability = 0.85  # 15% encounter rate (1.0 - 0.85 = 0.15)


func _ready():
	SignalManager.connect("instantiate_battle", battle)
	randomize()
	# Get the TallGrass layer specifically
	if tiles_node:
		tall_grass_layer = tiles_node.get_node("TallGrass")
		if tall_grass_layer:
			print("TallGrass layer found successfully!")
		else:
			print("Error: TallGrass layer not found under Tiles node")
	else:
		print("Error: Tiles node not found!")
	
func _process(_delta):
	get_input()
	
func _physics_process(_delta):
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)
	
	if !GameManager.is_battle:
		move()
		get_tile_below_player()
	
func get_input():
	if GameManager.is_battle:
		move_direction = Vector2.ZERO
	else:
		# movement
		if Input.is_action_pressed("ui_down"):
			move_direction = Vector2.DOWN
			$AnimationPlayer.play("down")
		elif Input.is_action_pressed("ui_up"):
			move_direction = Vector2.UP
			$AnimationPlayer.play("up")
		elif Input.is_action_pressed("ui_left"):
			move_direction = Vector2.LEFT
			$AnimatedSprite2D.flip_h = false
			$AnimationPlayer.play("left")
		elif Input.is_action_pressed("ui_right"):
			move_direction = Vector2.RIGHT
			$AnimatedSprite2D.flip_h = true
			$AnimationPlayer.play("right")

		# Idle animations
		if Input.is_action_just_released("ui_down"):
			move_direction = Vector2.ZERO
			$AnimationPlayer.play("idle_down")
		if Input.is_action_just_released("ui_up"):
			move_direction = Vector2.ZERO
			$AnimationPlayer.play("idle_up")
		if Input.is_action_just_released("ui_left"):
			move_direction = Vector2.ZERO
			$AnimationPlayer.play("idle_left")
		if Input.is_action_just_released("ui_right"):
			move_direction = Vector2.ZERO
			$AnimationPlayer.play("idle_right")

func move():
	move_direction = move_direction.normalized()
	velocity += move_direction * speed 
	velocity = velocity.limit_length(max_speed)
	move_and_slide()


func get_tile_below_player():
	# Check if tall_grass_layer exists before using it
	if not tall_grass_layer:
		print("TallGrass layer not available, skipping encounter check")
		return
	
	# get tile position below player
	var tile_below: Vector2i = tall_grass_layer.local_to_map(position)
	
	# check if player is on a new tile
	if current_tile != tile_below:
		current_tile = tile_below
		print("Current tile: ", current_tile)
		
		# check if there's a tall grass tile at this position
		var grass_tile_source_id = tall_grass_layer.get_cell_source_id(tile_below)
		is_on_tall_grass = grass_tile_source_id != -1  # -1 means no tile
		
		if is_on_tall_grass:
			print("Stepped on tall grass!")
			
			# calculate probability of a random encounter
			random_encounter = randf()
			print("Random encounter roll: ", random_encounter, " (need > ", probability, ")")
			
			if random_encounter > probability:
				print("Battle triggered!")
				battle()
		else:
			print("Not on tall grass")
	
	# Update grass status
	if not is_on_tall_grass:
		is_on_tall_grass = false


func battle():
	# instantiate the battle scene
	GameManager.is_battle = true
	var battle_instance = battle_scene.instantiate()
	add_child(battle_instance)
