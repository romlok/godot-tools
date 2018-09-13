# Node which keeps its parent looking at the target node
tool
extends "BaseOther.gd"

export(Vector3) var up_vector = Vector3(0, 1, 0)
export(bool) var negative_z = true # 


func do_process(delta):
	# Make the parent look at the target
	var flip_z = 1 if negative_z else -1
	var new_basis = parent.global_transform.looking_at(
		target.global_transform.origin * flip_z, up_vector
	).basis
	var parent_quat = Quat(parent.global_transform.basis)
	var target_quat = Quat(new_basis)
	var diff = (parent_quat + -target_quat).length_squared()
	if interpolate_speed > 0.001 and diff > 0.000001:
		parent.global_transform.basis = Basis(
			parent_quat.slerp(target_quat, interpolate_speed * delta)
		)
	elif diff > 0:
		parent.global_transform.basis = new_basis
