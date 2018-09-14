# Controls the parent Node like it's your head
extends Node

signal mouselook_toggled(enabled)

var parent

export(bool) var enabled = true setget set_enabled
export(bool) var mouselook = false setget set_mouselook
export(Vector2) var mouselook_scale = Vector2(PI / 360, PI / 360)
export(float) var mouselook_hold_timeout = 0.3
var mouselook_hold_timer
export(float) var min_pitch = -PI / 2
export(float) var max_pitch = PI / 2
var last_mouse_pos = Vector2()
var used_actions = [
	"mouselook_toggle",
]
export(bool) var consume_events = true

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
	
func _ready():
	# Make sure all the actions we expect exist,
	# so we don't spew errors for unused functionality
	for action in used_actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	
	set_enabled(enabled)
	
func _enter_tree():
	parent = get_parent()
	

func _unhandled_input(event):
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
		var new_y = parent.rotation.y
		var new_x = parent.rotation.x
		new_y -= event.relative.x * mouselook_scale.x
		new_x -= event.relative.y * mouselook_scale.y
		# Make sure we don't go upside-down
		if new_x < min_pitch:
			new_x = min_pitch
		elif new_x > max_pitch:
			new_x = max_pitch
		
		parent.rotation.x = new_x
		parent.rotation.y = new_y
		if consume_events:
			get_tree().set_input_as_handled()
		Input.warp_mouse_position(last_mouse_pos)
		
	