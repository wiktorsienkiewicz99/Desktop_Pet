extends Node
enum PetState {IDLE, MOVE_TO, SLEEP, LOVING, IN_AIR, DRAGGING, HIDE, EAT }
var current_state: int = PetState.IDLE
# Expose enum globally
const PetStateEnum = PetState
signal state_changed(new_state)

func set_state(new_state):
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)  # Notify other scripts
		print("STATE SET: ", new_state)
