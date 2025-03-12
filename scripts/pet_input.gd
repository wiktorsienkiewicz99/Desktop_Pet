extends Node
@onready var state = get_parent().get_node("PetState")
@onready var StateEnum = state.get("PetStateEnum")




func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		state.set_state(StateEnum.DRAGGING)
	if Input.is_action_just_released("left_click"):
		state.set_state(StateEnum.LOVING)
