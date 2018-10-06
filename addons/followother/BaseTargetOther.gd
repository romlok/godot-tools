# Base script for nodes which alter the parent in response to a target
tool
extends "BaseParentAffecter.gd"

# Configuration
export(NodePath) var target_path setget set_target_path
export(String) var target_bone = "" setget set_target_bone
export(float) var interpolate_speed = 0

var target setget set_target

func set_target_path(val):
	# Sets a new target NodePath
	target_path = val
	if target_path != null and is_inside_tree():
		set_target(get_node(target_path))
	else:
		target = null
	
func set_target_bone(val):
	target_bone = val
	check_bone(target, target_bone)
	
func set_target(val):
	# Sets or clears a new target Spatial node
	if val == null:
		# Wipe out the stored values
		target = null
		return
	
	# Otherwise, make sure we have what we expect
	if typeof(val) == TYPE_OBJECT and val is Spatial:
		pass
	else:
		print("WARN: Target for '{name}' not a Spatial: '{path}'".format({
			"name": name,
			"path": str(target_path),
		}))
		target = null
		return
	
	target_path = get_path_to(val)
	target = val
	# Listen for if the target disappears
	if not target.is_connected("tree_exited", self, "_on_lost_target"):
		target.connect("tree_exited", self, "_on_lost_target")
	
	# Re-set the bone to trigger any warnings
	set_target_bone(target_bone)
	
	# Active tool scripts have all their vars wiped when saved,
	# but _ready doesn't get called. So we fetch parent again here.
	parent = get_parent()
	

func _ready():
	set_target_path(target_path)
func _enter_tree():
	set_target_path(target_path)
	

func is_config_valid():
	# Returns whether this node's configuration is fit for purpose
	if target == null:
		return false
	if target_bone:
		# Make sure the specified bone exists
		if not target is Skeleton:
			return false
		if target.find_bone(target_bone) == -1:
			return false
	return .is_config_valid()
	
func get_target_global_transform():
	# Returns the global transform of the target (node or bone)
	return get_node_or_bone_global_transform(target, target_bone)
	

func _on_lost_target():
	# The target we had has left the building
	target = null
	# Wait a bit and try to reconnect (in case of eg. "change type")
	if is_inside_tree():
		yield(get_tree(), "idle_frame")
		set_target_path(target_path)
	
