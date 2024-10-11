extends StateMachineState

func _process(_delta: float) -> void:
	pass

func enter_state() -> void:
	super.enter_state()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	our_state_machine.switch_state("Credits")

func _on_play_pressed() -> void:
	our_state_machine.switch_state("Play")
