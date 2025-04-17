extends Window
#test
@onready var _Camera: Camera2D = $Camera2D
var sprite_size: Vector2       = Vector2.ZERO
var last_position: Vector2i = Vector2i.ZERO
var velocity: Vector2i = Vector2i.ZERO
var position_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	if get_parent() is Sprite2D:
		sprite_size = get_parent().texture.get_size()
		print("sprite 2d size: ", sprite_size)
	elif  get_parent() is AnimatedSprite2D:
		sprite_size = get_parent().sprite_frames.get_frame_texture(get_parent().name + '_idle', 0).get_size()
		print("Animated sprite 2d size: ", sprite_size)
	# Set the anchor mode to "Fixed top-left"
	# Easier to work with since it corresponds to the window coordinates
	_Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	position_offset = -(sprite_size /  2)
	self.size = sprite_size
	print("OFFSET: ", position_offset)
	close_requested.connect(queue_free) # Actually close the window when clicking the close button

func _process(delta: float) -> void:
	velocity = position - last_position
	last_position = position
	_Camera.position = get_camera_pos_from_window()
	self.position = get_parent().position + position_offset

func get_camera_pos_from_window()->Vector2i:
	return position + velocity
