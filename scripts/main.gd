'''
TODO:
	olac multi zwierzaki
	anmimacje
	ulepszyc zachowania
	dac wybór zwirzaka
	build
	przetestowac
	)'''

extends Node

@onready var _MainWindow: Window = get_window()
var pet_scene = preload("res://Scenes/pet.tscn")
var current_pet: Node = null# Store the current pet instance
var names = ["Panko", "Ksenia", "Mochi"]

func spawn_pet():

	var pet_name = names[randi() % 3]
	var new_pet = pet_scene.instantiate()  
	new_pet.start_offset = randi() % 800 - 400
	new_pet.name = pet_name
	add_child(new_pet)
	current_pet = new_pet  # Store reference to the current pet
	set_windows(get_tree().root)
			# Print pet info
	print("Spawned Pet:", new_pet.name, "| Position:", new_pet.global_position, "| Start Offset:", new_pet.start_offset)


func _ready():
	# Enable per-pixel transparency, required for transparent windows but has a performance cost
	# Can also break on some systems
	ProjectSettings.set_setting("display/window/per_pixel_transparency/allowed", true)
	# Set the window settings - most of them can be set in the project settings
	_MainWindow.borderless = true		# Hide the edges of the window
	_MainWindow.unresizable = true		# Prevent resizing the window
	_MainWindow.always_on_top = true	# Force the window always be on top of the screen
	_MainWindow.gui_embed_subwindows = false # Make subwindows actual system windows <- VERY IMPORTANT
	_MainWindow.transparent = true		# Allow the window to be transparent
	# Settings that cannot be set in project settings
	_MainWindow.transparent_bg = true	# Make the window's background transparent

	set_windows(get_tree().root)
	update_passthrough()
	
func _process(delta: float) -> void:
	camera_position(get_tree().root)
	if Input.is_action_pressed("quit_game"):
		get_tree().quit()  # Close all windows and exit the game
		
func update_passthrough():
	var screen_size = DisplayServer.window_get_size()  # Get the full window size
	var passthrough_area = PackedVector2Array([
		Vector2(0, 0),  # Top-left corner
		Vector2(0, screen_size.y)  # Bottom-left corner
	])
	
	DisplayServer.window_set_mouse_passthrough(passthrough_area, 0)
	
	# FIXED find_nodes_of_type function
func set_windows(node: Node):
	if node is Window:
		node.world_2d = _MainWindow.world_2d
		node.always_on_top = true
		node.transparent = true
		node.borderless = true
		node.transparent_bg = true
	for child in node.get_children():
		set_windows(child)
		
func camera_position(node: Node):
	if node is Camera2D:
		node.position = get_window().position
	for child in node.get_children():
		camera_position(child)
