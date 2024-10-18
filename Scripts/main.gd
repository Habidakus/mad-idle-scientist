extends Control

var options_screen : MarginContainer

func _ready() -> void:
	options_screen = $Options
	options_screen.hide()

func _input(event):
	if event is InputEventKey:
		if (event as InputEventKey).keycode == KEY_ESCAPE:
			if (event as InputEventKey).is_released():
				if options_screen.visible:
					$Options.hide()
				else:
					$Options.show()

func _on_click_sound_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !toggled_on)
	var button : Button = find_child("ClickSoundButton") as Button
	if toggled_on:
		button.text = "Currently On"
	else:
		button.text = "Currently Off"

func _on_rant_sound_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Ranting"), !toggled_on)
	var button : Button = find_child("RantSoundButton") as Button
	if toggled_on:
		button.text = "Currently On"
	else:
		button.text = "Currently Off"
