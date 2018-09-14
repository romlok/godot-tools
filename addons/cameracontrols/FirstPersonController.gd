# Controls the parent Node like it's a camera stuck to your head

extends Node

signal camera_moved
signal camera_mouselook_toggled(enabled)

export(NodePath) var fulcrum_path = NodePath("..")
var fulcrum

var mouselook = false setget set_mouselook
var mouselook_scale = Vector2(PI / 360, PI / 360)
var mouselook_hold_timeout = 0.3
var mouselook_hold_timer
var vertical_limits = [-PI / 2, PI / 2]
var last_mouse_pos = Vector2()
var fov_min = 10
var fov_max = 90
var fov_step = 5
var used_actions = [
	"mouselook_toggle",
	"camera_zoom_in",
	"camera_zoom_out",
]
export(bool) var consume_events = false

func set_mouselook(val):
	var changed = (mouselook != bool(val))
	mouselook = bool(val)
	if mouselook:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if changed:
			Input.warp_mouse_position(last_mouse_pos)
	if changed:
		emit_signal("camera_mouselook_toggled", mouselook)
	
func _ready():
	# Make sure all the actions we expect exist,
	# so we don't spew errors for unused functionality
	for action in used_actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	# Work out which node we're affecting
	fulcrum = get_node(fulcrum_path)
	if fulcrum == null:
		fulcrum = self
	

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		emit_signal("camera_moved")
	

func _unhandled_input(event):
	if not current:
		# Not the currently active camera, so blerp
		return
	
	# Extreme closeup
	if event.is_action_pressed("camera_zoom_in"):
		fov = max(fov_min, fov - fov_step)
		if consume_events:
			get_tree().set_input_as_handled()
		return
	if event.is_action_pressed("camera_zoom_out"):
		fov = min(fov_max, fov + fov_step)
		if consume_events:
			get_tree().set_input_as_handled()
		return
	
	# Mouselook toggling
	if event.is_action_pressed("mouselook_toggle"):
		if not mouselook:
			last_mouse_pos = event.position
		set_mouselook(not mouselook)
		if consume_events:
			get_tree().set_input_as_handled()
		# We allow hold-and-drag mouselook for long presses
		mouselook_hold_timer = get_tree().create_timer(mouselook_hold_timeout)
		return
	if event.is_action_released("mouselook_toggle"):
		# We un-mouselook if the toggle had been held down long enough
		if mouselook_hold_timer != null and mouselook_hold_timer.time_left <= 0:
			if mouselook:
				set_mouselook(false)
			if consume_events:
				get_tree().set_input_as_handled()
			return
		
	if not mouselook:
		# Not currently on rotation
		return
	
	if event is InputEventMouseMotion:
		# Mouselook ahoy!
		var new_y = fulcrum.rotation.y
		var new_x = fulcrum.rotation.x
		new_y -= event.relative.x * mouselook_scale.x
		new_x -= event.relative.y * mouselook_scale.y
		# Make sure we don't go upside-down
		if new_x < vertical_limits[0]:
			new_x = vertical_limits[0]
		elif new_x > vertical_limits[1]:
			new_x = vertical_limits[1]
		
		fulcrum.rotation.x = new_x
		fulcrum.rotation.y = new_y
		if consume_events:
			get_tree().set_input_as_handled()
		Input.warp_mouse_position(last_mouse_pos)
		
	