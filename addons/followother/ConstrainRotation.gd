# Node which keeps its parent facing within certain bounds
tool
extends "BaseParentAffecter.gd"

# Configuration
export(float) var max_pitch_degrees = 0
export(float) var max_yaw_degrees = 0
export(bool) var negative_z = true
# Constraints are always relative to our grandparent's orientation
var up_vector = Vector3(0, 1, 0)


func do_process(delta):
	var parent_trans = get_parent_global_transform()
	var basis = parent_trans.basis
	var rest_basis = get_parent_global_rest_transform().basis
	if negative_z:
		rest_basis = rest_basis.rotated(rest_basis.y, PI)
	
	if max_yaw_degrees > 0:
		# Constrain in the XZ plane
		var correction = get_constraint_correction(
			basis.z,
			rest_basis.z,
			rest_basis.y.normalized(),
			deg2rad(max_yaw_degrees)
		)
		if correction:
			basis = basis.rotated(rest_basis.y, correction)
		
	if max_pitch_degrees > 0:
		# Constrain in the YZ plane
		var correction = get_constraint_correction(
			basis.z,
			basis.z.slide(rest_basis.y),
			basis.x.normalized(),
			deg2rad(max_pitch_degrees)
		)
		if correction:
			basis = basis.rotated(basis.x.normalized(), correction)
		
	parent_trans.basis = basis
	set_parent_global_transform(parent_trans)
	
func get_constraint_correction(vector, rest_vector, axis_normal, max_radians):
	# Returns the correction needed to keep the `vector` within
	# `max_radians` around `axis_normal` of the `rest_vector`.
	var current_angle = vector.slide(axis_normal).angle_to(
		rest_vector.slide(axis_normal)
	)
	var extra_angle = current_angle - max_radians
	if extra_angle <= 0:
		# Within bounds, nothing needs to be done
		return 0
	# Work out which direction around the axis we need to rotate
	var direction = sign(vector.dot(rest_vector.cross(axis_normal)))
	return extra_angle * direction
	
