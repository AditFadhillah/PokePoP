extends CharacterBody2D

# player variables
@export var speed = 40
@export var max_speed = 100
@export var FRICTION: float = 0.15
var is_alive = true
var move_direction = Vector2.ZERO

# tile data
var is_on_encounter_tile = false
var current_tile: Vector2i
var current_region: String = ""
@onready var tiles_node = get_tree().current_scene.get_node("Tiles")

# Region tile layers
@onready var tall_grass_layer: TileMapLayer  # Forest
@onready var dry_kelp_layer: TileMapLayer    # Beach/Sand
@onready var ash_bramble_layer: TileMapLayer # Volcano
@onready var swamp_reed_layer: TileMapLayer  # Swamp

# battle variables
var rng = RandomNumberGenerator.new()
var random_encounter
var battle_scene = preload("res://Scenes/Battle/battle.tscn")
var probability = 0.85  # 15% encounter rate (1.0 - 0.85 = 0.15)


func _ready():
	SignalManager.connect("instantiate_battle", battle)
	randomize()
	# Get all region tile layers
	if tiles_node:
		tall_grass_layer = tiles_node.get_node("TallGrass")
		dry_kelp_layer = tiles_node.get_node("DryKelp")
		ash_bramble_layer = tiles_node.get_node("AshBramble")
		swamp_reed_layer = tiles_node.get_node("SwampReed")
		
		if tall_grass_layer and dry_kelp_layer and ash_bramble_layer and swamp_reed_layer:
			print("All region layers found successfully!")
		else:
			print("Warning: Some region layers not found")
	else:
		print("Error: Tiles node not found!")
	
func _process(_delta):
	get_input()
	
func _physics_process(_delta):
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)
	
	if !GameManager.is_battle and !GameManager.is_inventory:
		move()
		get_tile_below_player()
	
func get_input():
	if GameManager.is_battle or GameManager.is_inventory:
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
	# Check if tile layers exist
	if not tall_grass_layer or not dry_kelp_layer or not ash_bramble_layer or not swamp_reed_layer:
		print("Region layers not available, skipping encounter check")
		return
	
	# Get tile position below player (use any layer for position calculation)
	var tile_below: Vector2i = tall_grass_layer.local_to_map(position)
	var region_found = false
	
	# Check if player is on a new tile
	if current_tile != tile_below:
		current_tile = tile_below
		print("Current tile: ", current_tile)
		
		# Check which region the player is on
		
		# Check TallGrass (Forest)
		if tall_grass_layer.get_cell_source_id(tile_below) != -1:
			current_region = "Forest"
			is_on_encounter_tile = true
			region_found = true
			print("Stepped on Forest (TallGrass)!")
		
		# Check DryKelp (Beach/Sand)
		elif dry_kelp_layer.get_cell_source_id(tile_below) != -1:
			current_region = "Beach"
			is_on_encounter_tile = true
			region_found = true
			print("Stepped on Beach (DryKelp)!")
		
		# Check AshBramble (Volcano)
		elif ash_bramble_layer.get_cell_source_id(tile_below) != -1:
			current_region = "Volcano"
			is_on_encounter_tile = true
			region_found = true
			print("Stepped on Volcano (AshBramble)!")
		
		# Check SwampReed (Swamp)
		elif swamp_reed_layer.get_cell_source_id(tile_below) != -1:
			current_region = "Swamp"
			is_on_encounter_tile = true
			region_found = true
			print("Stepped on Swamp (SwampReed)!")
		else:
			is_on_encounter_tile = false
			current_region = ""
			print("Not on any encounter tile")
		
		# If on an encounter tile, check for random encounter
		if is_on_encounter_tile:
			random_encounter = randf()
			print("Random encounter roll: ", random_encounter, " (need > ", probability, ")")
			
			if random_encounter > probability:
				print("Battle triggered in region: ", current_region)
				battle()
	
	# Update encounter status
	if not region_found:
		is_on_encounter_tile = false
		current_region = ""


func battle():
	# instantiate the battle scene with region information
	GameManager.is_battle = true
	var battle_instance = battle_scene.instantiate()
	# Pass the current region to the battle scene
	battle_instance.set_region(current_region)
	add_child(battle_instance)
