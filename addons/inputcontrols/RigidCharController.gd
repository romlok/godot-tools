# Adds character controls to the parent RigidBody
#
extends Node

var parent

export(bool) var enabled = true setget set_enabled
export(bool) var consume_events = true
export(float) var forward_force = 20.0
export(float) var back_force = 20.0
export(float) var left_force = 20.0
export(float) var right_force = 20.0
export(float) var up_force = 20.0
export(float) var down_force = 20.0
export(bool) var negative_z = true
export(float) var yaw_force = 5.0
export(float) var roll_force = 5.0
# "Immediate rotation" sets linear_velocity directly,
# rather than applying a torque force.
export(bool) var immediate_rotation = false

# The orientation_node can be used to override which node is used to orient
# the directions of force. If not specified, this uses the parent node.
export(NodePath) var orientation_node_path setget set_orientation_node_path
var orientation_node setget set_orientation_node

var move_direction = Vector3()
var yaw_direction = 0
var roll_direction = 0
var used_actions = [
	"move_forward",
	"move_back",
	"move_left",
	"move_right",
	"move_up",
	"move_down",
	"yaw_left",
	"yaw_right",
	"roll_left",
	"roll_right",
]

func set_enabled(val):
	enabled = val
	set_process_unhandled_input(val)
	set_physics_process(val)
	
func set_orientation_node_path(val):
	orientation_node_path = val
	if is_inside_tree():
		orientation_node = get_node(orientation_node_path)
	
func set_orientation_node(val):
	orientation_node = val
	orientation_node_path = val.get_path()
	

func get_global_basis():
	var node = orientation_node
	if not "global_transform" in node:
		node = parent
	return node.global_transform.basis
	

func _ready():
	# (Re)Apply exported values
	set_enabled(enabled)
	set_orientation_node_path(orientation_node_path)
	# Make sure all the actions we expect exist,
	# so we don't spew errors for unused functionality
	for action in used_actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	
func _enter_tree():
	parent = get_parent()
	

func _physics_process(delta):
	# Move the parent as needed
	var global_basis = get_global_basis()
	if move_direction.length_squared():
		# Calculate the appropriate force
		var x_force = move_direction.dot(Vector3(1, 0, 0))
		x_force *= left_force if x_force > 0 else right_force
		var y_force = move_direction.dot(Vector3(0, 1, 0))
		y_force *= up_force if y_force > 0 else down_force
		var z_force = move_direction.dot(Vector3(0, 0, 1))
		z_force *= forward_force if z_force > 0 else back_force
		
		# Apply our force in the global space
		var global_dir = global_basis * move_direction
		var move_force = global_dir * (abs(x_force) + abs(y_force) + abs(z_force))
		if negative_z:
			move_force = move_force.rotated(global_basis.y, PI)
		
		parent.apply_impulse(Vector3(0, 0, 0), move_force * delta)
		
	if immediate_rotation:
		# Rotate by changing the linear velocity directly
		var yaw = (yaw_force / PI) * yaw_direction
		var roll = (roll_force / PI) * roll_direction
		parent.angular_velocity = Vector3(0, yaw, roll)
		
	elif yaw_direction or roll_direction:
		# We apply two equal-but-opposite forces to the sides
		# so that the net force is (in theory) pure torque
		## TODO: We can use apply_torque_impulse in 3.1
		var offset = global_basis * Vector3(1, 0, 0)
		var torque_force = global_basis * Vector3(
			0,
			roll_force * roll_direction / 2,
			-yaw_force * yaw_direction / 2
		)
		parent.apply_impulse(offset, torque_force * delta)
		parent.apply_impulse(-offset, -torque_force * delta)
	

func _unhandled_input(event):
	# Handle button-controlled directional movement
	if event.is_action("move_forward") or event.is_action("move_back"):
		move_direction.z = int(Input.is_action_pressed("move_forward"))
		move_direction.z -= int(Input.is_action_pressed("move_back"))
		if consume_events:
			get_tree().set_input_as_handled()
	if event.is_action("move_left") or event.is_action("move_right"):
		move_direction.x = int(Input.is_action_pressed("move_left"))
		move_direction.x -= int(Input.is_action_pressed("move_right"))
		if consume_events:
			get_tree().set_input_as_handled()
	if event.is_action("move_up") or event.is_action("move_down"):
		move_direction.y = int(Input.is_action_pressed("move_up"))
		move_direction.y -= int(Input.is_action_pressed("move_down"))
		if consume_events:
			get_tree().set_input_as_handled()
	# Prevent strafe-running
	move_direction = move_direction.normalized()
	
	# And rotation
	if event.is_action("yaw_left") or event.is_action("yaw_right"):
		yaw_direction = int(Input.is_action_pressed("yaw_left"))
		yaw_direction -= int(Input.is_action_pressed("yaw_right"))
		if consume_events:
			get_tree().set_input_as_handled()
		return
	if event.is_action("roll_left") or event.is_action("roll_right"):
		roll_direction = int(Input.is_action_pressed("roll_left"))
		roll_direction -= int(Input.is_action_pressed("roll_right"))
		if consume_events:
			get_tree().set_input_as_handled()
		return
	
