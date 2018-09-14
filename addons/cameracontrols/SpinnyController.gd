# Controls the parent Node like it's the middle a potter's wheel
extends "fps_camera.gd"

var mousepan = false setget set_mousepan
var pan_speed = 4
var pan_direction = Vector3()
var pan_enabled = true setget set_pan_enabled
var move_speed = 0.2
var distance_min = 1
var distance_max = 10
var ground_plane = Plane()

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
	
func set_pan_enabled(val):
	# Set whether or not this camera can pan
	pan_enabled = bool(val)
	mousepan = false
	

func _init():
	# Spinnycam has more controls
	used_actions += [
		"camera_pan_forward",
		"camera_pan_back",
		"camera_pan_left",
		"camera_pan_right",
		"camera_pan_drag",
		"camera_move_toward",
		"camera_move_away",
	]
func _ready():
	# Define the ground plane
	var fulcrum_pos = fulcrum.global_transform.origin
	var ground_normal = Vector3(0, 1, 0)
	ground_plane = Plane(
		ground_normal,
		fulcrum_pos.dot(ground_normal)
	)
	# Look at the fulcrum
	transform = transform.looking_at(fulcrum_pos, Vector3(0, 1, 0))
	vertical_limits = [-PI / 2.1, 0]
	

func get_ground_projection(coords):
	# Returns the ground coords of for viewport (mouse) coords
	return ground_plane.intersects_ray(
		project_ray_origin(coords),
		project_ray_normal(coords)
	)
	

func _process(delta):
	# Move the fulcrum as needed
	if pan_enabled and pan_direction.length_squared():
		# Work out the relative direction on the ground plane
		var fulcrum_dir = fulcrum.transform.basis * pan_direction
		var plane_dir = fulcrum_dir.slide(Vector3(0, 1, 0)).normalized()
		fulcrum.global_translate(plane_dir * pan_speed * delta)
		
	
func _unhandled_input(event):
	if not current:
		# Don't respond if we're not active
		return
	
	# Get all up in your face
	if event.is_action_pressed("camera_move_toward"):
		translation.z = max(distance_min, translation.z - move_speed)
		if consume_events:
			get_tree().set_input_as_handled()
		return
	if event.is_action_pressed("camera_move_away"):
		translation.z = min(distance_max, translation.z + move_speed)
		if consume_events:
			get_tree().set_input_as_handled()
		return
		
	# Handle panning of the camera by dragging the mouse
	if pan_enabled and event.is_action("camera_pan_drag"):
		if event.is_pressed():
			if get_ground_projection(event.position) != null:
				set_mousepan(true)
		else:
			set_mousepan(false)
		if consume_events:
			get_tree().set_input_as_handled()
		return
		
	if mousepan and event is InputEventMouseMotion:
		# Move the fulcrum so that the mouse appears fixed on the ground plane
		var old_grab_pos = get_ground_projection(event.position - event.relative)
		var new_grab_pos = get_ground_projection(event.position)
		if old_grab_pos != null and new_grab_pos != null:
			fulcrum.global_translate(old_grab_pos - new_grab_pos)
		if consume_events:
			get_tree().set_input_as_handled()
		return
		
	# Handle button-controlled directional panning
	if event.is_action("camera_pan_forward") or event.is_action("camera_pan_back"):
		pan_direction.z = int(Input.is_action_pressed("camera_pan_back"))
		pan_direction.z -= int(Input.is_action_pressed("camera_pan_forward"))
		pan_direction = pan_direction.normalized()
		if consume_events:
			get_tree().set_input_as_handled()
		return
	if event.is_action("camera_pan_left") or event.is_action("camera_pan_right"):
		pan_direction.x = int(Input.is_action_pressed("camera_pan_right"))
		pan_direction.x -= int(Input.is_action_pressed("camera_pan_left"))
		pan_direction = pan_direction.normalized()
		if consume_events:
			get_tree().set_input_as_handled()
		return
		
	
