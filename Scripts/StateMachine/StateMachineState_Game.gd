extends StateMachineState

var click_count : int = 0 : set = set_click_count
var money : int = 0 : set = set_money
var money_label : Label = null
var main_button : Button = null
var unlock_button : Button = null
var augment_button : Button = null
var workshops_button : Button = null
var augment_eta : Label = null
var oppossum_attr : Label = null
var oppossum_value : Label = null
var generate_money_tab : Control = null
var workshop_tab : Control = null
var tab_container : TabContainer = null
var main_button_stage : int = 0
var main_button_stages = {
	0: ["Tinker", 0, 1, "Put away your tinkering!\nBecome a coder."],
	1: ["Code", 10, 5, "Stop coding!\nTeach others your brilliance."],
	2: ["Mentor", 100, 10, "Bah, I'm thinking too small.\nLet me plan!"],
	3: ["Architect", 1000, 20, "Surely there is a market\nfor my brilliance!"],
	4: ["Patent", 10000, 50, "The fools don't understand me\nI will show them!"],
	5: ["Scheme", 100000, 100, "(((should not see this)))"],
}

var workshop_unlock_amount : int = 3500

var augment_remainder : float = 0
var augment_amount : float = 0
var augment_stage_multiplier : float = 1.5
var augment_button_stage : int = 0
var augment_button_unlock_fraction : float = 0
var augment_button_stages = {
	0: [50, 0, 1.5, "Odds Fish, I could train oppossums to do this!"],
	1: [100, 250, 0.4, "I need more oppossums!"],
	2: [200, 500, 0.3, "Onward, my marsupials!"],
	3: [400, 1000, 0.2, "Type with your tails if need be!"],
}

enum TabRef {
	GENERATE_MONEY_TAB,
	WORKSHOP_TAB,
}
enum TabAction {
	HIDE_TAB,
	SHOW_TAB,
	HIGHLIGHT_TAB,
	IS_HIDDEN,
}

func find_label(label_name : String) -> Label:
	var label = find_child(label_name) as Label
	assert(label != null, "%s could not find label child %s" % [name, label_name])
	return label
func find_button(button_name : String) -> Button:
	var button = find_child(button_name) as Button
	assert(button != null, "%s could not find button child %s" % [name, button_name])
	return button
func find_control(control_name : String) -> Control:
	var control = find_child(control_name) as Control
	assert(control != null, "%s could not find control child %s" % [name, control_name])
	return control
func find_tab_container(tc_name : String) -> TabContainer:
	var tc = find_child(tc_name) as TabContainer
	assert(tc != null, "%s could not find tab container child %s" % [name, tc_name])
	return tc

func _ready() -> void:
	money = 0
	
	tab_container = find_tab_container("TabContainer");
	
	money_label = find_label("MoneyValue")
	
	main_button = find_button("Button")
	main_button.text = main_button_stages[main_button_stage][0]
	
	unlock_button = find_button("UnlockButton")
	unlock_button.hide()

	augment_button = find_button("AugmentButton")
	augment_button.hide()
	augment_eta = find_label("AugmentETA")
	augment_eta.hide()
	
	oppossum_attr = find_label("OpposumAttr")
	oppossum_attr.hide()
	oppossum_value = find_label("OpposumValue")
	oppossum_value.hide()
	
	generate_money_tab = find_control("Generate Money");
	workshop_tab = find_control("Workshops");
	change_tab(TabRef.GENERATE_MONEY_TAB, TabAction.SHOW_TAB)
	change_tab(TabRef.WORKSHOP_TAB, TabAction.HIDE_TAB)

	workshops_button = find_button("WorkshopsButton");
	workshops_button.hide()
	
func get_tab_index(tab: TabRef) -> int:
	var idx : int = -1;
	match tab:
		TabRef.GENERATE_MONEY_TAB:
			idx = tab_container.get_tab_idx_from_control(generate_money_tab)
		TabRef.WORKSHOP_TAB:
			idx = tab_container.get_tab_idx_from_control(workshop_tab)
	assert(idx != -1, "Did not find tab %s in %s" % [TabRef.find_key(tab), tab_container.name])
	return idx

func change_tab(tab : TabRef, change : TabAction) -> void:
	var idx : int = get_tab_index(tab)
	match change:
		TabAction.HIDE_TAB:
			tab_container.set_tab_hidden(idx, true)
		TabAction.SHOW_TAB:
			tab_container.set_tab_hidden(idx, false)
		TabAction.HIGHLIGHT_TAB:
			assert(!tab_container.is_tab_hidden(idx), "Can't highlight of Tab.%s - still hidden" % TabRef.find_key(tab))
			if tab_container.current_tab != idx:
				print("TODO: implement highlight of Tab.%s" % TabRef.find_key(tab))
		_:
			assert(false, "Do not understand the %s action to perform on %s.%s" % [TabAction.find_key(change), tab_container.name, TabRef.find_key(tab)])

func query_tab(tab : TabRef, query : TabAction) -> bool:
	var idx : int = get_tab_index(tab)
	match query:
		TabAction.IS_HIDDEN:
			return tab_container.is_tab_hidden(idx)
		_:
			assert(false, "Do not understand the %s query to perform on %s.%s" % [TabAction.find_key(query), tab_container.name, TabRef.find_key(tab)])
	return false
	
func _process(delta: float) -> void:
	update_augment_button_fraction(delta, 1)
	if augment_amount > 0:
		augment_remainder += delta * augment_amount * main_button_stages[main_button_stage][2]
		oppossum_value.text = "$%.2f/sec" % (augment_amount * main_button_stages[main_button_stage][2])
		if augment_remainder >= 1.0:
			money += (int)(augment_remainder)
			augment_remainder -= floor(augment_remainder)

func update_augment_button_fraction(amount: float, index: int) -> void:
	if amount == 0:
		return
	if augment_button_stage >= augment_button_stages.size():
		return
	if augment_button.visible:
		return
	var fractionizer : float = augment_button_stages[augment_button_stage][index]
	if fractionizer == 0:
		return
		
	augment_button_unlock_fraction += amount / fractionizer

	var percent : float = augment_button_unlock_fraction * 100.0
	#var temp = "%.1f%% stage=%d" % [percent, augment_button_stage]

	if augment_button_unlock_fraction >= 1.0:
		augment_button.text = augment_button_stages[augment_button_stage][3]
		augment_button.show()
		augment_eta.hide()
		change_tab(TabRef.GENERATE_MONEY_TAB, TabAction.HIGHLIGHT_TAB)
	elif augment_button_unlock_fraction >= augment_button_stages[augment_button_stage][2]:
		if augment_eta.visible == false:
			augment_eta.show()
			change_tab(TabRef.GENERATE_MONEY_TAB, TabAction.HIGHLIGHT_TAB)
		var a : float = (augment_button_unlock_fraction - augment_button_stages[augment_button_stage][2]) / (1.0 - augment_button_stages[augment_button_stage][2])
		if a > 1:
			a = 1;
		augment_eta.modulate.a = a
		augment_eta.text = "%.1f%%" % percent;

func set_money(new_value : int) -> void:
	money = new_value
	if money > 0:
		money_label.text = "${0}".format([money])
	if main_button_stage + 1 < main_button_stages.size():
		if money >= main_button_stages[main_button_stage + 1][1]:
			unlock_button.text = main_button_stages[main_button_stage][3]
			unlock_button.show()
			change_tab(TabRef.GENERATE_MONEY_TAB, TabAction.HIGHLIGHT_TAB)
	if money >= workshop_unlock_amount && workshops_button.visible == false:
		if query_tab(TabRef.WORKSHOP_TAB, TabAction.IS_HIDDEN):
			workshops_button.show()
			change_tab(TabRef.GENERATE_MONEY_TAB, TabAction.HIGHLIGHT_TAB)

func set_click_count(new_value : int) -> void:
	click_count = new_value
	update_augment_button_fraction(1.0, 0)

func _on_button_pressed() -> void:
	click_count += 1
	money += main_button_stages[main_button_stage][2]

func _on_unlock_button_pressed() -> void:
	click_count += 1
	unlock_button.hide()
	main_button_stage += 1
	main_button.text = main_button_stages[main_button_stage][0]

func _on_augment_button_pressed() -> void:
	click_count += 1
	augment_button_unlock_fraction = 0
	augment_button_stage += 1
	augment_button.hide()
	if augment_amount == 0:
		oppossum_attr.show();
		oppossum_value.show();
		change_tab(TabRef.GENERATE_MONEY_TAB, TabAction.HIGHLIGHT_TAB)
		augment_amount = 1.0
	else:
		augment_amount *= augment_stage_multiplier

func _on_workshops_button_pressed() -> void:
	click_count += 1
	workshops_button.hide()
	change_tab(TabRef.WORKSHOP_TAB, TabAction.SHOW_TAB)
	change_tab(TabRef.WORKSHOP_TAB, TabAction.HIGHLIGHT_TAB)
