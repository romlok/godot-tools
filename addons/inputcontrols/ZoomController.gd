# Adds zoom controls to the parent node
#
extends Node

var parent

export(bool) var enabled = true setget set_enabled

export(float) var tween_time = 0.1
var tween:Tween

# Zooming by moving closer or further away
export(bool) var change_translation = true
export(float) var translation_min = 1
export(float) var translation_max = 100
# Speed is applied to continuous zoom operations
export(float) var translation_speed = 10
# Step is applied to discrete zoom changes (eg. mousewheel "clicks")
export(float) var translation_step = 5
# The axis which defines the direction of zooming in
export(Vector3) var translation_axis = Vector3(0, 0, -1)

# Zooming using camera FOV changes
export(bool) var change_fov = false
export(float) var fov_min = 10
export(float) var fov_max = 120
export(float) var fov_speed = 10
export(float) var fov_step = 5

# For continuous zoom, we track how fast we're zooming in or out
var zooming_speed = 0
var used_actions = [
	"zoom_in",
	"zoom_out",
	"zoom_in_step",
	"zoom_out_step",
	"zoom_in_max",
	"zoom_out_max",
]

func set_enabled(val):
	enabled = val
	set_process_unhandled_input(val)
	

func _ready():
	set_enabled(enabled)
	tween = Tween.new()
	add_child(tween)
	# Make sure all the actions we expect exist,
	# so we don't spew errors for unused functionality
	for action in used_actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	
func _enter_tree():
	parent = get_parent()
	

func _process(delta):
	# Move the parent as needed
	if zooming_speed != 0:
		if change_translation:
			parent.translate(translation_axis * zooming_speed * translation_speed * delta)
		if change_fov:
			parent.fov -= zooming_speed * fov_speed * delta
		apply_bounds()
	
func _unhandled_input(event):
	# Handle discrete zoom
	var discrete_zoom = 0
	if event.is_action("zoom_in_step"):
		discrete_zoom = 1
		get_tree().set_input_as_handled()
	elif event.is_action("zoom_out_step"):
		discrete_zoom = -1
		get_tree().set_input_as_handled()
	
	if discrete_zoom != 0:
		if change_translation:
			var new_trans = parent.translation + (discrete_zoom * translation_axis * translation_step)
			new_trans = bound_translation(new_trans)
			if tween_time > 0:
				interpolate_translation(new_trans)
			else:
				parent.translation = new_trans
			
		if change_fov:
			var new_fov = parent.fov - (discrete_zoom * fov_step)
			new_fov = bound_fov(new_fov)
			if tween_time > 0:
				interpolate_fov(new_fov)
			else:
				parent.fov = new_fov
	
	# Handle continuous zoom
	if event.is_action("zoom_in") or event.is_action("zoom_out"):
		zooming_speed = int(Input.is_action_pressed("zoom_in"))
		zooming_speed -= int(Input.is_action_pressed("zoom_out"))
		get_tree().set_input_as_handled()
		return
	

func interpolate_translation(translation):
	tween.remove(parent, "translation")
	tween.interpolate_property(
			parent, "translation",
			null, translation,
			tween_time, Tween.TRANS_QUART, Tween.EASE_OUT
			)
	tween.start()
	
func interpolate_fov(fov):
	tween.remove(parent, "fov")
	tween.interpolate_property(
			parent, "fov",
			null, fov,
			tween_time, Tween.TRANS_QUART, Tween.EASE_OUT
			)
	tween.start()
	


func bound_translation(translation:Vector3):
	var distance = -translation_axis.dot(translation)
	# Possible strangenes if translation_axis isn't normalised
	if distance < translation_min:
		return -translation_axis * translation_min
	elif distance > translation_max:
		return -translation_axis * translation_max
	return translation

func bound_fov(fov:float):
	if fov < fov_min:
		return fov_min
	elif fov > fov_max:
		return fov_max
	return fov

func apply_bounds():
	# Bound the current zoom within the given range
	if change_translation:
		parent.translation = bound_translation(parent.translation)
	if change_fov:
		parent.fov = bound_fov(parent.fov)
