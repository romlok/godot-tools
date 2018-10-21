tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"MouselookController", "Node",
		preload("MouselookController.gd"), preload("icon_mouse.svg")
	)
	add_custom_type(
		"PanController", "Node",
		preload("PanController.gd"), preload("icon_mouse.svg")
	)
	add_custom_type(
		"KinematicCharController", "Node",
		preload("KinematicCharController.gd"), preload("icon_mouse.svg")
	)
	add_custom_type(
		"RigidCharController", "Node",
		preload("RigidCharController.gd"), preload("icon_mouse.svg")
	)
	
func _exit_tree():
	remove_custom_type("MouselookController")
	remove_custom_type("PanController")
	remove_custom_type("KinematicCharController")
	remove_custom_type("RigidCharController")
	
