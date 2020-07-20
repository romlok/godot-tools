# Base script for nodes which alter their parent
tool
extends Node

# Configuration
export(bool) var enabled = false setget set_enabled
export(bool) var physics_sync = false setget set_physics_sync
export(String) var parent_bone = "" setget set_parent_bone

var parent

func set_enabled(val):
	enabled = bool(val)
	if enabled:
		# Turn on what needs to be on
		parent = get_parent()
		set_physics_sync(physics_sync)
	else:
		# Switch everything off
		set_physics_process(false)
		set_process(false)
	
func set_physics_sync(val):
	val = bool(val)
	physics_sync = val
	
	if Engine.editor_hint:
		# The editor doesn't process physics
		val = false
	set_physics_process(val)
	set_process(not val)
	
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
	set_enabled(enabled)
func _enter_tree():
	parent = get_parent()
	set_enabled(enabled)
	
func _process(delta):
	if not enabled:
		return
	if not is_config_valid():
		return
	do_process(delta)
func _physics_process(delta):
	if not enabled:
		return
	if not is_config_valid():
		return
	do_process(delta)
	
func is_config_valid():
	# Returns whether this node's configuration is fit for purpose
	# Extend this method in subclasses if need be,
	# but remember to also `return .is_config_valid()`
	if parent == null:
		return false
	if parent_bone:
		# Make sure the specified bone exists
		if not parent is Skeleton:
			return false
		if parent.find_bone(parent_bone) == -1:
			return false
	return true
	
func do_process(_delta):
	# To be overridden
	pass
	

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
		parent.set_bone_global_pose_override(bone_id, rel_trans, 1, true)
	else:
		parent.global_transform = trans
	
func get_parent_global_rest_transform():
	# Returns the rest global transform for the parent (node or bone)
	if parent_bone:
		var bone_id = parent.find_bone(parent_bone)
		return parent.global_transform * parent.get_bone_rest(bone_id)
	else:
		var grandparent = parent.get_parent()
		if "global_transform" in grandparent:
			return parent.get_parent().global_transform
		else:
			return Transform()
