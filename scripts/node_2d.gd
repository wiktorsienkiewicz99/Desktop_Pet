extends Node2D  # Use Node2D for proper movement

@onready var sprite_pet = $AnimatedSprite2D
@onready var collision_shape = $AnimatedSprite2D/Area2D/CollisionShape2D
@onready var area2d = $AnimatedSprite2D/Area2D  # Reference to Area2D

var velocity: Vector2 = Vector2(0, 0)  # Initial movement speed
var acceleration: int = 100  # Acceleration factor for smooth movement
var max_speed: int       = 300  # Maximum walking speed
var gravity: int         = 300  # Gravity strength
var bounce_factor: float = 0.4  # Bounce strength (1 = full energy, <1 = loses energy)
var taskbar_margin: int  = 62  # Prevents pet from colliding with the taskbar
var on_floor: bool      = false  # Tracks if the pet is on the floor
var friction: float = 0.99  # Friction factor (reduces velocity when sliding)
var floor_drag: float = 0.02  # Additional drag for slowing down gradually
var roaming_timer: int = 0  # Timer for changing movement direction
var roaming_interval: float = 3.0  # Default interval before direction changes
var target_direction: int   = 1  # 1 for right, -1 for left
var dragging: bool        = false  # Tracks if the pet is being dragged
var drag_offset: Vector2 = Vector2.ZERO  # Offset between mouse and pet position
var last_mouse_position: Vector2 = Vector2.ZERO  # Stores the last mouse position
var mouse_velocity: Vector2      = Vector2.ZERO  # Stores the calculated mouse velocity

func _ready():
	area2d.input_pickable = true  # Ensure Area2D detects clicks
	area2d.connect("input_event", Callable(self, "_on_Area2D_input_event"))  # Ensure signal is connected

	# Set window to fullscreen
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	# Enable transparent, borderless, always-on-top window
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)

	# Center the pet
	center_pet()

	# Start continuous movement
	set_roaming_interval(3.0)

	# Set passthrough to allow clicking only on the CollisionShape2D
	update_passthrough()

func _process(delta: float) -> void:
	if dragging:
		var mouse_pos: Vector2 = get_global_mouse_position()
		mouse_velocity = (mouse_pos - last_mouse_position) / delta  # Calculate mouse velocity
		last_mouse_position = mouse_pos  # Store last mouse position
		global_position = mouse_pos + drag_offset  # Follow mouse with offset
		update_passthrough()  # Ensure passthrough updates dynamically
	else:
		apply_gravity(delta)
		check_collisions()
		apply_friction(delta)
		update_passthrough()  # Ensure passthrough updates dynamically

		# **Roaming Logic**
		if on_floor:
			roaming_timer += delta
			if roaming_timer >= roaming_interval:
				roaming_timer = 0
				set_roaming_interval(randf_range(2.0, 5.0))  # Change direction at random intervals
				change_direction()

			# Smooth acceleration
			velocity.x = move_toward(velocity.x, target_direction * max_speed, acceleration * delta)

# **🛠 Center the Pet in the Middle of the Screen**
func center_pet():
	var screen_size: Vector2i = DisplayServer.window_get_size()
	global_position = screen_size / 2  # Move pet to center of the screen

# **🛠 Set Roaming Interval (Changes Direction After X Seconds)**
func set_roaming_interval(seconds: float):
	roaming_interval = seconds
	print("Changing direction in " + str(seconds) + " seconds.")

# **🛠 Change Direction Smoothly**
func change_direction():
	target_direction *= -1  # Reverse direction
	sprite_pet.flip_h = (target_direction == -1)  # Flip sprite when changing direction
	print("I am now walking " + ("left" if target_direction == -1 else "right"))

# **🛠 Apply Gravity**
func apply_gravity(delta):
	velocity.y += gravity * delta  # Apply gravity effect
	position += velocity * delta  # Move pet down

# **🛠 Apply Friction (Force Loss) When Sliding on Floor**
func apply_friction(delta):
	if on_floor:
		velocity.x *= friction  # Apply friction to slow down movement
		if abs(velocity.x) < floor_drag:  # Stop if speed is too low
			velocity.x = 0

# **🛠 Collisions & Bouncing on Borders**
func check_collisions():
	var screen_size: Vector2i = DisplayServer.window_get_size()
	var shape_size            = collision_shape.shape.size * collision_shape.scale / 2  # Half-size of CollisionShape

	# **Bottom Collision (Ground - Adjusted for Taskbar Margin)**
	var bottom_limit = screen_size.y - shape_size.y - taskbar_margin
	if position.y >= bottom_limit:
		position.y = bottom_limit
		velocity.y *= -bounce_factor  # Bounce

		if abs(velocity.y) < 1:
			if not on_floor:
				print("I am on floor")
			on_floor = true
		else:
			on_floor = false  # If bouncing, not on the floor

	# **Top Collision (Ceiling)**
	if position.y <= shape_size.y:
		position.y = shape_size.y
		velocity.y *= -bounce_factor  # Bounce off the ceiling

	# **Right Wall Collision**
	if position.x >= screen_size.x - shape_size.x:
		position.x = screen_size.x - shape_size.x
		velocity.x *= -bounce_factor  # Bounce off right wall
		change_direction()  # Change direction when hitting a wall

	# **Left Wall Collision**
	if position.x <= shape_size.x:
		position.x = shape_size.x
		velocity.x *= -bounce_factor  # Bounce off left wall
		change_direction()  # Change direction when hitting a wall

# **🛠 Drag & Drop Logic (Now with Momentum!)**
func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			print("Pet clicked! Dragging started.")
			dragging = true
			velocity = Vector2.ZERO  # Stop movement while dragging
			drag_offset = global_position - get_global_mouse_position()  # Store mouse offset
			last_mouse_position = get_global_mouse_position()  # Store initial mouse position
		elif not event.pressed:
			print("Dragging stopped. Pet resumes movement with momentum!")
			dragging = false  
			velocity = mouse_velocity * 0.2  # Apply momentum when dropping

# **🛠 Updated Transparent Click-Through Logic (Only on CollisionShape2D)**
func update_passthrough():
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var shape_size: Vector2 = collision_shape.shape.size * collision_shape.scale
		var top_left = collision_shape.global_position - shape_size / 2 
		var bottom_right = collision_shape.global_position + shape_size / 2

		# Define only the pet's shape as non-pass-through, everything else click-through
		var passthrough_area: PackedVector2Array = PackedVector2Array([
			top_left, Vector2(bottom_right.x, top_left.y), 
			bottom_right, Vector2(top_left.x, bottom_right.y)
		])
		DisplayServer.window_set_mouse_passthrough(passthrough_area)
