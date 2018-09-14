# Controls the parent Node like it's the middle a potter's wheel
extends "FirstPersonController.gd"

export(bool) var mousepan = false setget set_mousepan
export(float) var pan_speed = 4
var pan_plane = Plane()
var pan_direction = Vector3()

func set_mousepan(val):
	if mouselook:
		# Can't look and pan at the same time
		return
	mousepan = bool(val)
	
func set_mouselook(val):
	if mousepan:
		# Can't look and pan at the same time
		return false
	.set_mouselook(val)
	

func _init():
	# Spinnycam has more controls
	used_actions += [
		"pan_forward",
		"pan_back",
		"pan_left",
		"pan_right",
		"pan_mouse_drag",
	]
func _ready():
	# Define the ground plane for dragging
	var pan_normal = parent.global_transform.basis.y
	pan_plane = Plane(
		pan_normal,
		parent.global_transform.origin.dot(pan_normal)
	)
	

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
		var parent_dir = parent.transform.basis * pan_direction
		var pan_normal = parent.global_transform.basis.y
		var plane_dir = parent_dir.slide(pan_normal).normalized()
		parent.global_translate(plane_dir * pan_speed * delta)
		
	
func _unhandled_input(event):
	# Handle panning of the camera by dragging the mouse
	if event.is_action("pan_mouse_drag"):
		if event.is_pressed():
			if get_ground_projection(event.position) != null:
				set_mousepan(true)
		else:
			set_mousepan(false)
		if consume_events:
			get_tree().set_input_as_handled()
		return
		
	if mousepan and event is InputEventMouseMotion:
		# Move the parent so that the mouse appears fixed on the pan plane
		var old_grab_pos = get_ground_projection(event.position - event.relative)
		var new_grab_pos = get_ground_projection(event.position)
		if old_grab_pos != null and new_grab_pos != null:
			parent.global_translate(old_grab_pos - new_grab_pos)
		if consume_events:
			get_tree().set_input_as_handled()
		return
		
	# Handle button-controlled directional panning
	if event.is_action("pan_forward") or event.is_action("pan_back"):
		pan_direction.z = int(Input.is_action_pressed("pan_back"))
		pan_direction.z -= int(Input.is_action_pressed("pan_forward"))
		if consume_events:
			get_tree().set_input_as_handled()
		return
	if event.is_action("pan_left") or event.is_action("pan_right"):
		pan_direction.x = int(Input.is_action_pressed("pan_right"))
		pan_direction.x -= int(Input.is_action_pressed("pan_left"))
		if consume_events:
			get_tree().set_input_as_handled()
		return
		
	
