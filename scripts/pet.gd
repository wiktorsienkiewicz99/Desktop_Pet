extends Node2D

@onready var state = $PetState
@onready var movement = $PetMovement
@onready var StateEnum = state.get("PetStateEnum")
@onready var home = get_parent().get_node("Home")
@onready var sunflower = get_parent().get_node("Sunflower")
@export var start_offset: int = 0
var sprite_pet = self
var target_position

func _ready():
	# Center the pet
	movement.center_pet(start_offset)
	state.set_state(StateEnum.IDLE)
	# Update passthrough every 5 frames
	#update_passthrough()

func is_mouse_inside_sprite() -> bool:
	var sprite_size = self.sprite_frames.get_frame_texture(self.name + '_idle', 0).get_size()  # Get scaled texture size
	var sprite_pos = self.global_position - (sprite_size / 2)  # Adjust for centered pivot
	var sprite_rect = Rect2(sprite_pos, sprite_size)
	return sprite_rect.has_point(get_global_mouse_position())
	
func _check_state():
	if Input.is_action_pressed("left_click") and state.current_state != StateEnum.SLEEP and is_mouse_inside_sprite():
		state.set_state(StateEnum.DRAGGING)
	elif Input.is_action_just_pressed("left_click") and state.current_state == StateEnum.SLEEP:
		state.set_state(StateEnum.IDLE)
	elif movement.on_floor == false:
		state.set_state(StateEnum.IN_AIR)
	if Input.is_action_just_released("left_click") and state.current_state == StateEnum.IN_AIR:
		if home.mouse_inside_sprite():
			state.set_state(StateEnum.HIDE)
		else:
			state.set_state(StateEnum.IDLE)
	if Input.is_action_just_pressed("right_click") and state.current_state != StateEnum.DRAGGING and state.current_state != StateEnum.IN_AIR:
		self.state.set_state(StateEnum.LOVING)
		
func _process(delta):
	movement.handle_collisions(delta)
	movement.apply_friction()
	movement.check_floor()
	_check_state()
	#update_passthrough()
	
'''
func update_passthrough():
	if sprite_pet and sprite_pet.sprite_frames:
		var current_animation = sprite_pet.animation
		var current_frame = sprite_pet.frame
		var frame_texture = sprite_pet.sprite_frames.get_frame_texture(current_animation, current_frame)

		if frame_texture:
			var shape_size = frame_texture.get_size() * sprite_pet.scale  # Get the size of the current frame
			var pivot_offset = sprite_pet.offset * sprite_pet.scale  # Account for pivot offset

			# Correct position based on offset
			var top_left = global_position - (shape_size / 2) + pivot_offset  
			var bottom_right = global_position + (shape_size / 2) + pivot_offset 

			# Ensure the passthrough area does not go below the screen
			var screen_size = DisplayServer.window_get_size()
			top_left.y = max(0, top_left.y)  # Keep within screen bounds
			bottom_right.y = min(screen_size.y, bottom_right.y)

			var passthrough_area = PackedVector2Array([
				top_left, Vector2(bottom_right.x, top_left.y),
				bottom_right, Vector2(top_left.x, bottom_right.y)
			])
			DisplayServer.window_set_mouse_passthrough(passthrough_area)			
	'''
