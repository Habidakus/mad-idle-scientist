extends Node

class_name ControlDecorator

@export var loads_after : ControlDecorator = null

signal loading_completed

var target : Control = null
var our_state : StateMachineState = null

# Default Settings
var settings_default = {
	"scale": Vector2.ONE,
	"duration_in_seconds": 0.15,
	"self_modulate": Color.WHITE,
	"transition_type": Tween.TransitionType.TRANS_QUAD,
}
# Hover Settings
var settings_hover = {
	"scale": Vector2.ONE * 1.1,
	"duration_in_seconds": 0.15,
	"self_modulate": Color.WHITE,
	"transition_type": Tween.TransitionType.TRANS_QUAD,
}
# Loading Settings
var settings_loading = {
	"scale": Vector2.ZERO,
	"duration_in_seconds": 0.05,
	"self_modulate": Color(Color.WHITE, 0),
	"transition_type": Tween.TransitionType.TRANS_QUAD,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_parent() as Control
	assert(target != null, "{0} does not have a Control as a parent".format([name]))
	target.mouse_entered.connect(on_hover)
	target.mouse_exited.connect(off_hover)
	
	our_state = get_our_state(target)
	our_state.state_enter.connect(on_state_entered)
	
	if loads_after != null:
		loads_after.loading_completed.connect(on_load_after_completed)
	
	call_deferred("setup")

func on_hover() -> void:
	add_transition("hover", settings_hover, settings_hover["duration_in_seconds"], Callable())

func off_hover() -> void:
	add_transition("default-off-hover", settings_default, settings_hover["duration_in_seconds"], Callable())

func on_state_entered() -> void:
	add_transition("loading", settings_loading, 0.01, finished_loading)

func on_load_after_completed() -> void:
	add_transition("default-dependancy-loaded", settings_default, settings_default["duration_in_seconds"], signal_finished_loading)

func finished_loading() -> void:
	if loads_after == null:
		add_transition("default-state-entered", settings_default, settings_loading["duration_in_seconds"], signal_finished_loading)

func signal_finished_loading() -> void:
	loading_completed.emit()

var tween : Tween = null
var callback_after_tween_finished : Callable = Callable()

func invoke_tween_callback() -> void:
	var tmp : Callable = callback_after_tween_finished
	callback_after_tween_finished = Callable()
	tmp.call()

func add_transition(mode_name : String, settings, seconds : float, callback : Callable ) -> void:
	#print("Starting transition " + target.name + " to " + mode_name)

	if tween != null && tween.is_running():
		tween.kill()
		if callback_after_tween_finished.is_valid():
			invoke_tween_callback()
	
	callback_after_tween_finished = callback
	
	# In case we're already out of scene when this gets called
	var tree = get_tree()
	if tree != null:
		tween = tree.create_tween()
		tween.tween_property(target, "scale", settings["scale"], seconds).set_trans(settings["transition_type"])
		tween.parallel().tween_property(target, "self_modulate", settings["self_modulate"], seconds).set_trans(settings["transition_type"])
		if callback_after_tween_finished.is_valid():
			tween.tween_callback(invoke_tween_callback)
	else:
		print("add_transition(" + mode_name + ") called when " + name + ".get_tree() returned null")

func get_our_state(t) -> StateMachineState:
	while t != null:
		if t is StateMachineState:
			return t as StateMachineState
		t = t.get_parent()
	assert(false, "{0} does not have a StateMachineState as an ancestor".format(name))
	return null

func setup() -> void:
	target.pivot_offset = target.size / 2.0
	settings_default["scale"] = target.scale
	settings_hover["scale"] = target.scale * 1.1
	
