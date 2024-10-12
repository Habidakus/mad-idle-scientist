extends StateMachineState

var money : int = 0 : set = set_money
var money_label : Label = null
var main_button : Button = null
var unlock_button : Button = null
var main_button_stage : int = 0
var main_button_stages = {
	0: ["Tinker", 0, 1, "Put away your tinkering!\nBecome a coder."],
	1: ["Code", 10, 5, "Stop coding!\nTeach others your brilliance."],
	2: ["Mentor", 100, 10, "Bah, I'm thinking too small.\nLet me plan!"],
	3: ["Architect", 1000, 20, "Surely there is a market\nfor my brilliance!"],
	4: ["Patent", 10000, 50, "The fools don't understand me\nI will show them!"],
	5: ["Scheme", 100000, 100, "(((should not see this)))"],
}

func _ready() -> void:
	money = 0
	
	money_label = find_child("MoneyValue") as Label
	assert(money_label != null)
	
	main_button = find_child("Button") as Button
	assert(main_button != null)
	main_button.text = main_button_stages[main_button_stage][0]
	
	unlock_button = find_child("UnlockButton") as Button
	assert(unlock_button != null)
	unlock_button.hide()
	
func _process(_delta: float) -> void:
	pass

func set_money(new_value : int) -> void:
	money = new_value
	if main_button_stage + 1 < main_button_stages.size():
		if money >= main_button_stages[main_button_stage + 1][1]:
			unlock_button.text = main_button_stages[main_button_stage][3]
			unlock_button.show()

func _on_button_pressed() -> void:
	money += main_button_stages[main_button_stage][2]
	money_label.text = "${0}".format([money])

func _on_unlock_button_pressed() -> void:
	unlock_button.hide()
	main_button_stage += 1
	main_button.text = main_button_stages[main_button_stage][0]
