# Controls the parent Node like it's your head
extends Node

signal mouselook_toggled(enabled)

var parent

export(bool) var enabled = true setget set_enabled
export(bool) var mouselook = false setget set_mouselook
export(Vector2) var mouselook_scale = Vector2(1, 1) setget set_mouselook_scale
export(float) var mouselook_hold_timeout = 0.3
var mouselook_hold_timer
# We expose the min/max pitches as degrees, but use rads
export(float) var min_pitch = -89.9 setget set_min_pitch
export(float) var max_pitch = 89.9 setget set_max_pitch
var mouselook_scale_rads = Vector2()
var pitch_limits = [null, null]
var last_mouse_pos = Vector2()
var used_actions = [
	"mouselook_toggle",
]

func set_enabled(val):
	enabled = val
	set_process_unhandled_input(val)
	
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
		emit_signal("mouselook_toggled", mouselook)
	
func set_mouselook_scale(val):
	mouselook_scale = val
	# The exposed var is set in degrees turned per unit moused
	mouselook_scale_rads = mouselook_scale * (PI / 180)
	
func set_min_pitch(val):
	min_pitch = val
	# Remember: min is max because forward is -z
	pitch_limits[1] = -deg2rad(val)
	
func set_max_pitch(val):
	max_pitch = val
	# Remember: max is min because forward is -z
	pitch_limits[0] = -deg2rad(val)
	

func _ready():
	set_enabled(enabled)
	# Make sure all the actions we expect exist,
	# so we don't spew errors for unused functionality
	for action in used_actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	
func _enter_tree():
	parent = get_parent()
	

func _unhandled_input(event):
	# Mouselook toggling
	if event.is_action_pressed("mouselook_toggle"):
		if not mouselook:
			last_mouse_pos = event.position
		set_mouselook(not mouselook)
		get_tree().set_input_as_handled()
		if mouselook_hold_timeout > 0:
			# We allow hold-and-drag mouselook for long presses
			mouselook_hold_timer = get_tree().create_timer(mouselook_hold_timeout)
		return
	if event.is_action_released("mouselook_toggle"):
		# We un-mouselook if the toggle had been held down long enough
		if mouselook_hold_timeout <= 0:
			# Hold-mouselook is disabled
			pass
		elif mouselook_hold_timer != null and mouselook_hold_timer.time_left <= 0:
			if mouselook:
				set_mouselook(false)
			get_tree().set_input_as_handled()
			return
		
	if not mouselook:
		# Not currently on rotation
		return
	
	if event is InputEventMouseMotion:
		# Mouselook ahoy!
		var new_y = parent.rotation.y
		var new_x = parent.rotation.x
		new_y -= event.relative.x * mouselook_scale_rads.x
		new_x -= event.relative.y * mouselook_scale_rads.y
		# Make sure we don't go upside-down
		if new_x < pitch_limits[0]:
			new_x = pitch_limits[0]
		elif new_x > pitch_limits[1]:
			new_x = pitch_limits[1]
		
		parent.rotation.x = new_x
		parent.rotation.y = new_y
		get_tree().set_input_as_handled()
		Input.warp_mouse_position(last_mouse_pos)
		
	