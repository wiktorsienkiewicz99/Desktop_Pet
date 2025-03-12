#Test only, not implemented

extends Control
func _ready():
	print("liski, ", DisplayServer.window_get_current_screen())
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
