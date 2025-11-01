extends Control

@onready var pokemon_list = $CanvasLayer/UI/PokemonList/ScrollContainer/VBoxContainer
@onready var points_label = $CanvasLayer/UI/Header/PointsLabel
@onready var count_label = $CanvasLayer/UI/Header/CountLabel
@onready var anim = $CanvasLayer/AnimationPlayer

func _ready():
	# Show inventory with fade in
	anim.play("fade_in")
	
	# Connect to GameManager signal for real-time updates
	GameManager.pokemon_inventory_changed.connect(_on_pokemon_inventory_changed)
	
	# Populate inventory
	refresh_inventory()

func _process(_delta):
	# Allow closing with E key or Escape
	if Input.is_action_just_pressed("inventory"):
		close_inventory()

func refresh_inventory():
	# Clear existing items
	for child in pokemon_list.get_children():
		child.queue_free()
	
	# Update header info
	var captured_pokemon = GameManager.get_captured_pokemon()
	var total_points = GameManager.get_total_points()
	
	count_label.text = "Pokémon: " + str(captured_pokemon.size())
	points_label.text = "Points: " + str(total_points)
	
	# Add Pokémon items
	for pokemon in captured_pokemon:
		create_pokemon_item(pokemon)

func create_pokemon_item(pokemon_data: Dictionary):
	# Create a horizontal container for image and text
	var item_container = HBoxContainer.new()
	item_container.custom_minimum_size = Vector2(0, 40)
	
	# Create and add Pokemon image
	var pokemon_image = TextureRect.new()
	pokemon_image.custom_minimum_size = Vector2(32, 32)
	pokemon_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	pokemon_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Load Pokemon sprite based on name
	var image_path = "res://Assets/Sprites/Pokemons/" + pokemon_data.name.to_lower() + ".png"
	var texture = load(image_path)
	if texture:
		pokemon_image.texture = texture
	
	item_container.add_child(pokemon_image)
	
	# Add some spacing
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(10, 0)
	item_container.add_child(spacer)
	
	# Create text label
	var text_label = Label.new()
	text_label.text = pokemon_data.name + " (Lv" + str(pokemon_data.level) + ") - " + str(pokemon_data.points) + " pts"
	text_label.add_theme_font_size_override("font_size", 12)
	text_label.add_theme_color_override("font_color", Color.WHITE)
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	item_container.add_child(text_label)
	
	pokemon_list.add_child(item_container)

func close_inventory():
	anim.play("fade_out")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		GameManager.is_inventory = false
		queue_free()
	
	if anim_name == "fade_in":
		# Inventory is now fully opened
		pass

func _on_pokemon_inventory_changed():
	# Called when GameManager's Pokemon inventory changes
	refresh_inventory()
