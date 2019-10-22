# Node which keeps its parent transform the same as the target node's
#
# NB. Currently mirroring rotation ignores scale. Because Basis.
tool
extends "BaseTargetOther.gd"

# Configuration
export(bool) var follow_x = true
export(bool) var follow_y = true
export(bool) var follow_z = true
export(bool) var follow_rotation = true


func get_configuration_warning():
	return "hi"
	
func do_process(delta):
	if follow_x or follow_y or follow_z:
		mirror_position(delta)
	if follow_rotation:
		mirror_rotation(delta)
	
func mirror_position(delta):
	# Work out he actual point we're to follow
	var parent_trans = get_parent_global_transform()
	var parent_pos = parent_trans.origin
	var target_pos = get_target_global_transform().origin
	if not follow_x:
		target_pos.x = parent_pos.x
	if not follow_y:
		target_pos.y = parent_pos.y
	if not follow_z:
		target_pos.z = parent_pos.z
	
	var diff = parent_pos.distance_to(target_pos)
	if interpolate_speed > 0.001 and diff > 0.001:
		parent_trans.origin = parent_pos.linear_interpolate(
			target_pos,
			interpolate_speed * delta
		)
	elif diff > 0:
		parent_trans.origin = target_pos
	
	set_parent_global_transform(parent_trans)
	
func mirror_rotation(delta):
	var parent_trans = get_parent_global_transform()
	var target_trans = get_target_global_transform()
	var our_quat = parent_trans.basis.get_rotation_quat()
	var target_quat = target_trans.basis.get_rotation_quat()
	var diff = (our_quat + -target_quat).length_squared()
	if interpolate_speed > 0.001 and diff > 0.000001:
		parent_trans.basis = Basis(
			our_quat.slerp(target_quat, interpolate_speed * delta)
		)
	elif diff > 0:
		parent_trans.basis = target_trans.basis
	
	set_parent_global_transform(parent_trans)
	
