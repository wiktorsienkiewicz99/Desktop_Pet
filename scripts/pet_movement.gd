extends Node
@onready var pet: Node = get_parent()
# Movement Variables
var velocity: Vector2 = Vector2(0, 0)
var acceleration: int = randi () % 40 + 80
var max_speed: int       = randi () % 100 + 250
var gravity: int         = 300
var bounce_factor: float = 0.4
var friction: float      = 0.97
var floor_drag           = 0.02
var taskbar_margin = 36

var on_floor: bool       = false  # Tracks if pet is on ground
var floor_threshold: int    = 1
var roaming_timer: int      = 0
var roaming_interval: float = 3.0
var target_direction: int        = 1  # 1 (right) or -1 (left)
var drag_offset: Vector2         = Vector2.ZERO
var last_mouse_position: Vector2 = Vector2.ZERO
var mouse_velocity: Vector2      = Vector2.ZERO

func _ready() -> void:
	print("MY SPEED: ", max_speed)


func check_floor():
	on_floor = abs(velocity.y) < floor_threshold
	
func apply_friction():
	if on_floor:
		velocity.x *= friction
	if abs(velocity.x) < floor_drag:
		velocity.x = 0
		
func idle(delta):
	# Roaming logic
	if on_floor:
		roaming_timer += delta
		if roaming_timer >= roaming_interval:
			roaming_timer = 0
			set_roaming_interval(randf_range(2.0, 20.0))
			change_direction()

		# Smooth acceleration
		velocity.x = move_toward(velocity.x, target_direction * max_speed, acceleration * delta)
		pet.global_position += velocity * delta

func handle_dragging(delta):
	var mouse_pos = pet.get_global_mouse_position()  # Now using pet reference
	mouse_velocity = (mouse_pos - last_mouse_position) / delta
	last_mouse_position = mouse_pos
	pet.global_position = mouse_pos + drag_offset


func handle_collisions(delta):
	var screen_size: Vector2i = DisplayServer.window_get_size()
	# **Ground Collision**
	var bottom_limit: int = screen_size.y - taskbar_margin
	velocity.y += gravity * delta
	pet.global_position += velocity * delta
	if pet.global_position.y >= bottom_limit:
		pet.global_position.y = bottom_limit
		velocity.y *= -bounce_factor
	# **Ceiling Collision**
	if pet.global_position.y <= 0:
		pet.global_position.y = 0
		velocity.y *= -bounce_factor

	# **Wall Collision**
	if pet.global_position.x >= screen_size.x:
		pet.global_position.x = screen_size.x
		velocity.x *= -bounce_factor
		change_direction()

	if pet.global_position.x <= 0:
		pet.global_position.x = 0
		velocity.x *= -bounce_factor
		change_direction()

func set_roaming_interval(seconds):
	roaming_interval = seconds

func change_direction():
	target_direction *= -1
	pet.sprite_pet.flip_h = (target_direction == -1)

func center_pet(offset):
	var screen_size: Vector2i = DisplayServer.window_get_size()
	pet.global_position = Vector2i(screen_size.x / 2, screen_size.y) + Vector2i(offset, taskbar_margin)
