extends Control

signal pet_selected(pet_name)  # Define a signal

func _ready():
	print("Menu is ready")  # Debugging
	$VBoxContainer/Button.text = "Ksenia"
	$VBoxContainer/Button2.text = "Panko"
	$VBoxContainer/Button3.text = "Mochi"

	$VBoxContainer/Button.pressed.connect(_on_button_pressed.bind("Ksenia"))
	$VBoxContainer/Button2.pressed.connect(_on_button_pressed.bind("Panko"))
	$VBoxContainer/Button3.pressed.connect(_on_button_pressed.bind("Mochi"))

func _on_button_pressed(pet_name):
	print("Button clicked:", pet_name)  # Debugging: This should print in the output
	pet_selected.emit(pet_name)  # Emit signal instead of calling parent directly
	self.hide()
