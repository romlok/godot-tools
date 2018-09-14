tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"FirstPersonController", "Node",
		preload("FirstPersonController.gd"), preload("icon_mouse.svg")
	)
	add_custom_type(
		"SpinnyController", "Node",
		preload("SpinnyController.gd"), preload("icon_mouse.svg")
	)
	
func _exit_tree():
	remove_custom_type("FirstPersonController")
	remove_custom_type("SpinnyController")
	
