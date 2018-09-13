# Node which keeps its parent transform the same as the target node's
#
# NB. Currently mirroring rotation also mirrors scale. Because Basis.
tool
extends Node

# Confguration
export(NodePath) var target_path setget set_target_path
export(bool) var mirror_position = true
export(bool) var mirror_rotation = true
export(float) var interpolate_speed = 0

var parent
var target

func set_target_path(val):
	target_path = val
	if target_path != null and has_node(target_path):
		target = get_node(target_path)
	else:
		target = null
	

func _enter_tree():
	set_target_path(target_path)
	parent = get_parent()
	
func _exit_tree():
	target = null
	parent = null
	

func _process(delta):
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
		
	
