extends Sprite2D

func mouse_inside_sprite() -> bool:
	var sprite_size: Vector2 = self.texture.get_size()  # Get scaled texture size
	var sprite_pos: Vector2 = self.global_position - (sprite_size / 2)  # Adjust for centered pivot
	var sprite_rect: Rect2  = Rect2(sprite_pos, sprite_size)
	return sprite_rect.has_point(get_global_mouse_position())
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(DisplayServer.window_get_size().x - self.texture.get_size().x / 2, DisplayServer.window_get_size().y - self.texture.get_size().y / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("right_click") and mouse_inside_sprite():
		get_parent().spawn_pet()
		
