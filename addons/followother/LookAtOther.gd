# Node which keeps its parent looking at the target node
tool
extends "BaseOther.gd"

export(Vector3) var up_vector = Vector3(0, 1, 0)
export(bool) var negative_z = true # 


func do_process(delta):
	# Make the parent look at the target
	var parent_trans = get_parent_global_transform()
	var new_basis = parent_trans.looking_at(
		get_target_global_transform().origin, up_vector
	).basis
	if not negative_z:
		# We want to look with our +Z axis
		new_basis = new_basis.rotated(new_basis.y, PI)
	
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
	
