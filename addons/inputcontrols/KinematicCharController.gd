# Adds character controls to the parent KinematicBody
#
extends Node

var parent

export(bool) var enabled = true setget set_enabled
export(float) var move_speed = 50.0
export(float) var turn_speed = 1.0

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
		# Work out the relative direction in global space
		var parent_basis = parent.global_transform.basis
		var global_dir = parent_basis * move_direction.normalized()
		parent.move_and_slide(
			global_dir * move_speed * delta,
			parent_basis.y
		)
		
	if turn_direction:
		parent.rotate_y(turn_direction * turn_speed * delta)
	
func _unhandled_input(event):
	# Handle button-controlled directional movement
	if event.is_action("move_forward") or event.is_action("move_back"):
		move_direction.z = int(Input.is_action_pressed("move_back"))
		move_direction.z -= int(Input.is_action_pressed("move_forward"))
		get_tree().set_input_as_handled()
		return
	if event.is_action("move_left") or event.is_action("move_right"):
		move_direction.x = int(Input.is_action_pressed("move_right"))
		move_direction.x -= int(Input.is_action_pressed("move_left"))
		get_tree().set_input_as_handled()
		return
		
	# And rotation
	if event.is_action("turn_left") or event.is_action("turn_right"):
		turn_direction = int(Input.is_action_pressed("turn_left"))
		turn_direction -= int(Input.is_action_pressed("turn_right"))
		get_tree().set_input_as_handled()
		return
	
