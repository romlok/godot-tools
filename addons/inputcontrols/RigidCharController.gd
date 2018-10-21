# Adds character controls to the parent RigidBody
#
extends Node

var parent

export(bool) var enabled = true setget set_enabled
export(float) var forward_force = 20.0
export(float) var back_force = 20.0
export(float) var left_force = 20.0
export(float) var right_force = 20.0
export(bool) var negative_z = true

var move_direction = Vector3()
var turn_direction = 0.0
var used_actions = [
	"move_forward",
	"move_back",
	"move_left",
	"move_right",
	"turn_left",
	"turn_right",
]

func set_enabled(val):
	enabled = val
	set_process_unhandled_input(val)
	set_physics_process(val)
	

func _ready():
	set_enabled(enabled)
	# Make sure all the actions we expect exist,
	# so we don't spew errors for unused functionality
	for action in used_actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	
func _enter_tree():
	parent = get_parent()
	

func _physics_process(delta):
	# Move the parent as needed
	if move_direction.length_squared():
		var parent_basis = parent.global_transform.basis
		# Calculate the appropriate force
		var x_force = move_direction.dot(Vector3(1, 0, 0))
		x_force *= left_force if x_force > 0 else right_force
		var z_force = move_direction.dot(Vector3(0, 0, 1))
		z_force *= forward_force if z_force > 0 else back_force
		
		# Apply our force in the global space
		var global_dir = parent_basis * move_direction
		var move_force = global_dir * (abs(x_force) + abs(z_force))
		if negative_z:
			move_force = move_force.rotated(parent_basis.y, PI)
		
		parent.apply_impulse(Vector3(0, 0, 0), move_force * delta)
		
	if turn_direction:
		pass
	

func _unhandled_input(event):
	# Handle button-controlled directional movement
	if event.is_action("move_forward") or event.is_action("move_back"):
		move_direction.z = int(Input.is_action_pressed("move_forward"))
		move_direction.z -= int(Input.is_action_pressed("move_back"))
		get_tree().set_input_as_handled()
	if event.is_action("move_left") or event.is_action("move_right"):
		move_direction.x = int(Input.is_action_pressed("move_left"))
		move_direction.x -= int(Input.is_action_pressed("move_right"))
		get_tree().set_input_as_handled()
	# Prevent strafe-running
	move_direction = move_direction.normalized()
	
	# And rotation
	if event.is_action("turn_left") or event.is_action("turn_right"):
		turn_direction = int(Input.is_action_pressed("turn_left"))
		turn_direction -= int(Input.is_action_pressed("turn_right"))
		get_tree().set_input_as_handled()
		return
	
