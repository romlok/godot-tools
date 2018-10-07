# Node which keeps its parent transform within certain bounds
tool
extends "BaseParentAffecter.gd"

# Configuration
export(float) var max_pitch_degrees = 0
export(float) var max_yaw_degrees = 0
# Constraints are always relative to our grandparent's orientation
var up_vector = Vector3(0, 1, 0)


func do_process(delta):
	var parent_trans = get_parent_global_transform()
	var rest_basis = get_parent_global_rest_transform().basis
	if max_pitch_degrees > 0:
		# Constrain in the YZ plane
		var basis = parent_trans.basis
		var rest_plane = rest_basis.y
		var current_angle = basis.z.angle_to(basis.z.slide(rest_plane))
		if current_angle > deg2rad(max_pitch_degrees):
			# Move us to the max_pitch degrees
			var perp_normal = basis.z.cross(rest_plane).normalized()
			var direction = -sign(basis.z.dot(rest_plane))
			parent_trans.basis = basis.rotated(perp_normal, (current_angle - deg2rad(max_pitch_degrees)) * direction)
			
		
	if max_yaw_degrees > 0:
		# Constrain in the XZ plane
		var xz_forward = -rest_basis.z.slide(up_vector).normalized()
		var xz_facing = -parent_trans.basis.z.slide(up_vector).normalized()
		# Work out which way to rotate the max vector
		# A positive facing_side means the target is clockwise of -rest_basis.z
		var facing_side = sign(xz_facing.dot(rest_basis.x))
		var max_angle = deg2rad(max_yaw_degrees) * -facing_side
		var xz_max = xz_forward.rotated(up_vector, max_angle)
		
		if xz_facing.dot(xz_forward) < xz_max.dot(xz_forward):
			# We're further from forward than the max
			var angle = xz_facing.angle_to(xz_max)
			parent_trans.basis = parent_trans.basis.rotated(up_vector, angle * facing_side)
	
	set_parent_global_transform(parent_trans)
	
