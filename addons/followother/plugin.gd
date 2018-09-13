tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"FollowOther", "Node",
		preload("FollowOther.gd"), preload("icon_tween.svg")
	)
	add_custom_type(
		"LookAtOther", "Node",
		preload("LookAtOther.gd"), preload("icon_tween.svg")
	)
	
func _exit_tree():
	remove_custom_type("FollowOther")
	remove_custom_type("LookAtOther")
	
