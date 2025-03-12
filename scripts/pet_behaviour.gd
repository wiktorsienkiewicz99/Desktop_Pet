extends Node

@onready var state_manager = get_parent().get_node("PetState")
@onready var pet = get_parent()
@onready var movement = pet.get_node("PetMovement")
@onready var home = get_tree().get_first_node_in_group("Home")  # Assuming home has a group "Home"
@onready var sunflower = get_tree().get_first_node_in_group("Sunflower")  # Assuming sunflower has a group
@onready var StateEnum = state_manager.get("PetStateEnum")
var idle_timer = 0.0
const IDLE_TIME_BEFORE_SLEEP = 5.0  # Sleep after 5s of idle
var roaming_target = Vector2.ZERO
var loving_end_frame = 5


func _ready():
	state_manager.state_changed.connect(_on_pet_state_changed)  # Connect the signal

func _on_pet_state_changed():
	idle_timer = 0.0

func _process(delta):
	match state_manager.current_state:
		StateEnum.IDLE:
			handle_idle(delta)
		StateEnum.MOVE_TO:
			handle_move_to(delta)
		StateEnum.SLEEP:
			handle_sleep()
		StateEnum.IN_AIR:
			handle_in_air(delta)
		StateEnum.HIDE:
			handle_hide()
		StateEnum.EAT:
			handle_eat()
		StateEnum.DRAGGING:
			handle_dragging(delta)
		StateEnum.LOVING:
			handle_loving()

func handle_idle(delta):
	pet.play(pet.name + "_idle")
	movement.idle(delta)
	idle_timer += delta
	if idle_timer >= IDLE_TIME_BEFORE_SLEEP:
		state_manager.set_state(StateEnum.SLEEP)  # Transition to sleep
		idle_timer = 0.0

func handle_move_to(delta):
	#print("MOVING TO: ", pet.target_position)
	if pet.target_position and pet.global_position.distance_to(pet.target_position) > 10:
		pet.global_position = pet.global_position.move_toward(pet.target_position, 100 * delta)
	else:
		state_manager.set_state(StateEnum.IDLE)

func handle_sleep():
	#print("SLEEP")
	#pet_sprite.play("sleep")  # Play sleep animation
	pet.play(pet.name + "_sleep")  # Play sleep animation

func handle_in_air(delta):
	#print("IN AIR")
	pet.play(pet.name + "_in_air")
	movement.in_air(delta)
	if movement.on_floor:  # Example ground threshold
		print("FLOOR HIT! SWITCHING TO IDLE")
		state_manager.set_state(StateEnum.IDLE)

func handle_hide():
	#print("PET HIDDEN")
	if pet:  # Ensure pet exists before trying to free it
		print("removing pet ", get_tree().current_scene.current_pet)
		get_tree().current_scene.current_pet = null
		print(" state changed to ", get_tree().current_scene.current_pet)
		pet.queue_free()  # Remove the pet from the scene
		

func handle_eat():
	#print("I'M EATING")
	#pet_sprite.play("eat")
	pet.play(pet.name + "_eat")
	
func handle_dragging(delta):
	#print("DRAGGING")
	pet.play(pet.name + "_dragging")
	movement.handle_dragging(delta)
	return
	
func handle_loving():
	#print("LOVING")
	#pet_sprite.play("love")
	pet.play(pet.name + "_love")
	#if pet_sprite.frame == pet_sprite.frames:
	#if pet_sprite.frame == 5:
	if pet.frame == loving_end_frame:
		state_manager.set_state(StateEnum.IDLE)
