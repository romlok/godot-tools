# Base script for nodes which alter the parent in response to a target
tool
extends Node

# Configuration
export(NodePath) var target_path setget set_target_path
export(bool) var enabled = false setget set_enabled
export(float) var interpolate_speed = 0
export(bool) var physics_sync = false setget set_physics_sync

var parent
var target setget set_target

func set_target_path(val):
	# Sets a new target NodePath
	target_path = val
	if target_path != null and has_node(target_path):
		set_target(get_node(target_path))
	else:
		target = null
	
func set_target(val):
	# Sets or clears a new target Spatial node
	
	if val == null:
		# Wipe out the stored values
		target_path = null
		target = null
		return
	
	# Otherwise, make sure we have what we expect
	if typeof(val) == TYPE_OBJECT and val is Spatial:
		pass
	else:
		target = null
		return
	
	target_path = get_path_to(val)
	target = val
	# Listen for if the target disappears
	target.connect("tree_exited", self, "_on_lost_target")
	
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
	
func _process(delta):
	if parent == null or target == null:
		return
	do_process(delta)
func _physics_process(delta):
	if parent == null or target == null:
		return
	do_process(delta)
	

func _on_lost_target():
	# The target we had has left the building
	target = null
	# Wait a bit and try to reconnect (in case of eg. "change type")
	var tree = get_tree()
	if tree != null:
		yield(tree, "idle_frame")
		set_target_path(target_path)
	

func do_process(delta):
	# To be overridden
	pass
