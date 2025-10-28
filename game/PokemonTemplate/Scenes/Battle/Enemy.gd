extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var attack_damage = 4
@onready var hp_bar = $EnemyHPBar
@onready var enemy_name_label = $EnemyName
@onready var enemy_level_label = $EnemyLv
@onready var enemy_sprite = $EnemySprite
@export var max_hp = 25
var hp = 25
var is_alive = true

# Pokemon data storage
var current_pokemon_name = ""
var current_pokemon_level = 1

func _ready():
	SignalManager.connect("enemy_hp_changed", on_enemy_hp_changed)
	hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp

func set_pokemon(pokemon_name: String, level: int = 1):
	# Update the enemy to display the correct Pokémon
	current_pokemon_name = pokemon_name
	current_pokemon_level = level
	
	# Update UI elements
	enemy_name_label.text = pokemon_name
	enemy_level_label.text = str(level)
	
	# Load the appropriate sprite based on pokemon name
	var sprite_path = "res://Assets/Sprites/Pokemons/" + pokemon_name.to_lower() + ".png"
	var sprite_texture = load(sprite_path)
	if sprite_texture:
		enemy_sprite.texture = sprite_texture
	else:
		print("Warning: Could not load sprite for " + pokemon_name)

func get_hp():
	return hp

func _process(_delta):
	if hp <= 0 and is_alive:
		SignalManager.emit_signal("enemy_dead")
		print("enemy is dead")
		is_alive = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hit":
		#animation_player.play("attack")
		pass
		
	if anim_name == "attack":
		SignalManager.emit_signal("enemy_animation_finished")

func on_enemy_hp_changed(new_hp):
	hp -= new_hp
	hp_bar.value = hp
	print(hp)
