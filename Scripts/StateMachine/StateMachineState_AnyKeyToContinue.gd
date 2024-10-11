extends StateMachineState

@export var next_state : StateMachineState
@export var time_out_in_seconds : float = -1

var countdown : float = 0

func _process(delta: float) -> void:
	if time_out_in_seconds > 0:
		countdown += delta
		if countdown > time_out_in_seconds:
			our_state_machine.switch_state_internal(next_state)

func _input(event):
	handle_event(event)
func _unhandled_input(event):
	handle_event(event)

func handle_event(event):
	# We process on "released" instead of pressed because otherwise immediately
	# switching screens could still have the mouse being pressed on some other
	# screen's button.
	if event.is_released():
		if event is InputEventKey:
			our_state_machine.switch_state_internal(next_state)
		if event is InputEventMouseButton:
			our_state_machine.switch_state_internal(next_state)

func enter_state() -> void:
	countdown = 0
	super.enter_state()
