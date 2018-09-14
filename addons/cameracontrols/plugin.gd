tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"FPSController", "Node",
		preload("FPSController.gd"), preload("icon_mouse.svg")
	)
	add_custom_type(
		"RTSController", "Node",
		preload("RTSController.gd"), preload("icon_mouse.svg")
	)
	
func _exit_tree():
	remove_custom_type("FPSController")
	remove_custom_type("RTSController")
	
