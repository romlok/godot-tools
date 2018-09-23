# Base script for nodes which alter the parent in response to a target
tool
extends Node

# Configuration
export(NodePath) var target_path setget set_target_path
export(String) var target_bone = "" setget set_target_bone
export(bool) var enabled = false setget set_enabled
export(float) var interpolate_speed = 0
export(bool) var physics_sync = false setget set_physics_sync

var parent
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
	if target and target_bone:
		# Check that the specified bone is valid
		if not target is Skeleton:
			print("WARN: Target for '{name}' is not a Skeleton: '{path}'".format({
				"name": name,
				"path": str(target_path),
			}))
		elif target.find_bone(target_bone) == -1:
			print("WARN: Target for '{name}' does not have '{bone}' bone: '{path}'".format({
				"name": name,
				"bone": target_bone,
				"path": str(target_path),
			}))
	
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
	
func set_enabled(val):
	enabled = bool(val)
	if enabled:
		# Turn on what needs to be on
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
	

func _ready():
	set_enabled(enabled)
	set_target_path(target_path)
func _enter_tree():
	set_target_path(target_path)
	
func _process(delta):
	if not is_config_valid():
		return
	do_process(delta)
func _physics_process(delta):
	if not is_config_valid():
		return
	do_process(delta)
	

func is_config_valid():
	# Returns whether this node's configuration is fit for purpose
	if parent == null:
		return false
	if target == null:
		return false
	if target_bone:
		# Make sure the specified bone exists
		if not target is Skeleton:
			return false
		if target.find_bone(target_bone) == -1:
			return false
	return true
	
func get_target_global_transform():
	# Returns the global transform of the target
	# We assume that is_config_valid() == true. If not, on your head be it!
	if target_bone:
		# The "global" pose of a bone is actually relative to the skeleton
		var bone_id = target.find_bone(target_bone)
		return target.global_transform * target.get_bone_global_pose(bone_id)
	else:
		return target.global_transform
	

func _on_lost_target():
	# The target we had has left the building
	target = null
	# Wait a bit and try to reconnect (in case of eg. "change type")
	if is_inside_tree():
		yield(get_tree(), "idle_frame")
		set_target_path(target_path)
	

func do_process(delta):
	# To be overridden
	pass
