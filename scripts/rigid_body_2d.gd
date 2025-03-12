#First instance of project where pets and other objects were RigidBodies

extends RigidBody2D

var dragging = false
var drag_offset = Vector2.ZERO  # Stores the difference between pet and cursor

func _ready():
	input_pickable = true  # Enable click detection

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Pet clicked!")
		dragging = true
		freeze = true  # Freeze physics
		drag_offset = global_position - get_global_mouse_position()  # Store offset

	elif event is InputEventMouseButton and not event.pressed:
		dragging = false
		freeze = false  # Unfreeze when released

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset  # Apply offset
