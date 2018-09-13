# Node which keeps its parent transform the same as the target node's
#
# NB. Currently mirroring rotation also mirrors scale. Because Basis.
tool
extends Node

# Configuration
export(NodePath) var target_path setget set_target_path
export(bool) var mirror_position = true
export(bool) var mirror_rotation = true
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
		return
	
	target_path = get_path_to(val)
	target = val
	# Active tool scripts have all their vars wiped when saved,
	# but _ready doesn't get called. So we fetch parent again here.
	parent = get_parent()
	
func set_physics_sync(val):
	val = bool(val)
	physics_sync = val
	
	if Engine.editor_hint:
		# The editor doesn't process physics
		val = false
	set_physics_process(val)
	set_process(not val)
	

func _ready():
	set_physics_sync(physics_sync)
	set_target_path(target_path)
	

func _process(delta):
	do_process(delta)
func _physics_process(delta):
	do_process(delta)
	
func do_process(delta):
	if target == null or parent == null:
		return
	
	var diff
	if mirror_position:
		diff = parent.global_transform.origin.distance_to(target.global_transform.origin)
		if interpolate_speed > 0.001 and diff > 0.001:
			parent.global_transform.origin = parent.global_transform.origin.linear_interpolate(
				target.global_transform.origin,
				interpolate_speed * delta
			)
		elif diff > 0:
			parent.global_transform.origin = target.global_transform.origin
		
	if mirror_rotation:
		var our_quat = Quat(parent.global_transform.basis)
		var target_quat = Quat(target.global_transform.basis)
		diff = (our_quat + -target_quat).length_squared()
		if interpolate_speed > 0.001 and diff > 0.000001:
			parent.global_transform.basis = Basis(
				our_quat.slerp(target_quat, interpolate_speed * delta)
			)
		elif diff > 0:
			parent.global_transform.basis = target.global_transform.basis
		
	
