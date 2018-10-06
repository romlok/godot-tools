# Base script for nodes which alter their parent
tool
extends Node

# Configuration
export(String) var parent_bone = "" setget set_parent_bone

var parent

func set_parent_bone(val):
	parent_bone = val
	check_bone(parent, parent_bone)
	
func check_bone(node, bone_name):
	if node and bone_name:
		# Check that the specified bone is valid
		if not node is Skeleton:
			print("WARN: Node is not a Skeleton: '{name}/{path}'".format({
				"name": name,
				"path": str(get_path_to(node)),
			}))
		elif node.find_bone(bone_name) == -1:
			print("WARN: Skeleton does not have '{bone}' bone: '{name}/{path}'".format({
				"name": name,
				"bone": bone_name,
				"path": str(get_path_to(node)),
			}))
	
func _ready():
	parent = get_parent()
func _enter_tree():
	parent = get_parent()
	
func get_parent_global_transform():
	# Returns the global transform of the affected parent (node or bone)
	return get_node_or_bone_global_transform(parent, parent_bone)
	
func get_node_or_bone_global_transform(node, bone_name):
	# We assume that is_config_valid() == true. If not, on your head be it!
	if bone_name:
		# The "global" pose of a bone is actually relative to the skeleton
		var bone_id = node.find_bone(bone_name)
		return node.global_transform * node.get_bone_global_pose(bone_id)
	else:
		return node.global_transform
	
func set_parent_global_transform(trans):
	# Sets the global transform of the affected parent (node or bone)
	if parent_bone:
		var bone_id = parent.find_bone(parent_bone)
		var rel_trans = parent.global_transform.inverse() * trans
		parent.set_bone_global_pose(bone_id, rel_trans)
	else:
		parent.global_transform = trans
