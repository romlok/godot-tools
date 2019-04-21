# Adds pan controls to the parent node
#
extends Node

var parent

export(bool) var enabled = true setget set_enabled
export(bool) var mousepan = false
export(float) var pan_speed = 4
export(Vector3) var pan_normal = Vector3(0, 1, 0) setget set_pan_normal
var pan_plane = Plane()
var pan_direction = Vector3()
var used_actions = [
	"pan_forward",
	"pan_back",
	"pan_left",
	"pan_right",
	"pan_mouse_drag",
]

func set_enabled(val):
	enabled = val
	set_process_unhandled_input(val)
	
func set_pan_normal(val):
	pan_normal = val
	if parent != null:
		pan_plane = Plane(
			pan_normal,
			parent.global_transform.origin.dot(pan_normal)
		)
	

func _ready():
	set_enabled(enabled)
	set_pan_normal(pan_normal)
	# Make sure all the actions we expect exist,
	# so we don't spew errors for unused functionality
	for action in used_actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	
func _enter_tree():
	parent = get_parent()
	

func get_ground_projection(coords):
	# Returns the ground coords for viewport (mouse) coords
	var camera = get_viewport().get_camera()
	return pan_plane.intersects_ray(
		camera.project_ray_origin(coords),
		camera.project_ray_normal(coords)
	)
	

func _process(delta):
	# Move the parent as needed
	if pan_speed > 0 and pan_direction.length_squared():
		# Work out the relative direction on the ground plane
		var plane_z = parent.transform.basis.z.slide(pan_normal).normalized()
		var parent_yaw = Basis(
			plane_z.cross(pan_normal),
			pan_normal,
			plane_z
		)
		var plane_dir = (parent_yaw * pan_direction).normalized()
		parent.global_translate(plane_dir * pan_speed * delta)
		
	
func _unhandled_input(event):
	# Handle panning of the camera by dragging the mouse
	if event.is_action("pan_mouse_drag"):
		if event.is_pressed():
			if get_ground_projection(event.position) != null:
				mousepan = true
		else:
			mousepan = false
		get_tree().set_input_as_handled()
		return
		
	if mousepan and event is InputEventMouseMotion:
		# Move the parent so that the mouse appears fixed on the pan plane
		var old_grab_pos = get_ground_projection(event.position - event.relative)
		var new_grab_pos = get_ground_projection(event.position)
		if old_grab_pos != null and new_grab_pos != null:
			parent.global_translate(old_grab_pos - new_grab_pos)
		get_tree().set_input_as_handled()
		return
		
	# Handle button-controlled directional panning
	if event.is_action("pan_forward") or event.is_action("pan_back"):
		pan_direction.z = int(Input.is_action_pressed("pan_back"))
		pan_direction.z -= int(Input.is_action_pressed("pan_forward"))
		get_tree().set_input_as_handled()
		return
	if event.is_action("pan_left") or event.is_action("pan_right"):
		pan_direction.x = int(Input.is_action_pressed("pan_left"))
		pan_direction.x -= int(Input.is_action_pressed("pan_right"))
		get_tree().set_input_as_handled()
		return
		
	
