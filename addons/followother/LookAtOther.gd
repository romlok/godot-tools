# Node which keeps its parent looking at the target node
tool
extends "BaseTargetOther.gd"

export(Vector3) var up_vector = Vector3(0, 1, 0)
export(bool) var enable_pitching = true
export(bool) var negative_z = true
export(bool) var exorcist = true


func do_process(delta):
	# First work out where we're supposed to be looking
	var parent_trans = get_parent_global_transform()
	var target_point = get_target_global_transform().origin
	if not enable_pitching:
		# Find the equivalent point on our horizontal plane
		target_point = target_point.slide(up_vector)
		target_point += (up_vector * up_vector.dot(parent_trans.origin))
	var new_basis = parent_trans.looking_at(
		target_point, up_vector
	).basis
	
	if not exorcist:
		# We want to prevent turning a full 360
		var parent_vec = parent_trans.basis.z.normalized()
		var target_vec = new_basis.z.normalized()
		var parent_side_vec = parent_trans.basis.x.normalized()
		var rest_basis = get_parent_global_rest_transform().basis
		if sign(rest_basis.x.dot(parent_vec)) != sign(rest_basis.x.dot(target_vec)):
			# The parent and target are on opposite sides of forward
			if sign(parent_side_vec.dot(rest_basis.z)) != sign(parent_side_vec.dot(target_vec)):
				# Forward and the target are on opposite sides of the parent
				# Which means that we need to take the long route round
				# Which we do by changing our target to the mid-point on the long route
				target_point = parent_vec + target_vec + parent_trans.origin
				new_basis = parent_trans.looking_at(target_point, up_vector).basis
		
	if not negative_z:
		# We want to look with our +Z axis
		new_basis = new_basis.rotated(new_basis.y, PI)
	
	# Now make the parent actually look at the target
	var parent_quat = Quat(parent_trans.basis)
	var target_quat = Quat(new_basis)
	var diff = (parent_quat + -target_quat).length_squared()
	if interpolate_speed > 0.001 and diff > 0.000001:
		parent_trans.basis = Basis(
			parent_quat.slerp(target_quat, interpolate_speed * delta)
		)
	elif diff > 0:
		parent_trans.basis = new_basis
		
	set_parent_global_transform(parent_trans)
	
