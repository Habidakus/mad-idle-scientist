extends StateMachineState

var click_count : int = 0 : set = set_click_count
var money : int = 0 : set = set_money
var money_label : Label = null
var main_button : Button = null
var unlock_button : Button = null
var augment_button : Button = null
var workshops_button : Button = null
var hire_minion_button : Button = null
var build_workshop_button : Button = null
var list_of_workshops_grid : GridContainer = null
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

var cost_to_hire_next_minion : int = 1000
var cost_to_nire_next_minion_multiplier : float = 2
var cost_to_build_next_workshop : int = 1000
var cost_to_build_next_workshop_multiplier : float = 3

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
func find_grid_container(grid_name : String) -> GridContainer:
	var gc = find_child(grid_name) as GridContainer
	assert(gc != null, "%s could not find grid container child %s" % [name, grid_name])
	return gc

func _ready() -> void:
	
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
	
	hire_minion_button = find_button("HireMinion")
	update_minion_button()
	build_workshop_button = find_button("BuildWorkshop")
	update_workshop_button()
	
	generate_money_tab = find_control("Generate Money");
	generate_money_tab.show()
	workshop_tab = find_control("Workshops");
	change_tab(TabRef.GENERATE_MONEY_TAB, TabAction.SHOW_TAB)
	change_tab(TabRef.WORKSHOP_TAB, TabAction.HIDE_TAB)
	
	workshops_button = find_button("WorkshopsButton");
	workshops_button.hide()
	
	list_of_workshops_grid = find_grid_container("ListOfWorkshops");
	list_of_workshops_grid.hide();
	
	money = 3100

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
			if !tab_container.is_tab_disabled(idx):
				if tab_container.current_tab != idx:
					print("TODO: implement highlight of Tab.%s" % TabRef.find_key(tab))
			else:
				print("Can't highlight of Tab.%s - still hidden" % TabRef.find_key(tab))
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
	update_minion_button()
	update_workshop_button()

func update_minion_button() -> void:
	hire_minion_button.text = "Hire Minion\n$%.2f" % [cost_to_hire_next_minion]
	if money < cost_to_hire_next_minion:
		hire_minion_button.set_disabled(true)
	elif hire_minion_button.is_disabled():
		change_tab(TabRef.WORKSHOP_TAB, TabAction.HIGHLIGHT_TAB)
		hire_minion_button.set_disabled(false)

func update_workshop_button() -> void:
	build_workshop_button.text = "Build Workshop\n$%.2f" % [cost_to_build_next_workshop]
	if money < cost_to_build_next_workshop:
		build_workshop_button.set_disabled(true)
	elif build_workshop_button.is_disabled():
		change_tab(TabRef.WORKSHOP_TAB, TabAction.HIGHLIGHT_TAB)
		build_workshop_button.set_disabled(false)


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

func _on_hire_minion_pressed() -> void:
	click_count += 1
	money -= cost_to_hire_next_minion
	cost_to_hire_next_minion = (int) (cost_to_hire_next_minion * cost_to_nire_next_minion_multiplier)
	update_minion_button()

var workshop_name_index_a : int = -1
var workshop_name_index_b : int = -1
var workshop_name_index_c : int = -1
var some_primes : Array = [2749, 2909, 3083, 3259, 3433, 3581, 3733, 3749, 1709]
var workshop_name_stepper_a : int
var workshop_name_stepper_b : int
var workshop_name_stepper_c : int

func generate_workshop_name() -> String:
	if workshop_name_index_a == -1:
		var rng : RandomNumberGenerator = RandomNumberGenerator.new()
		workshop_name_index_a = rng.randi() % 100000;
		workshop_name_index_b = rng.randi() % 100000;
		workshop_name_index_c = rng.randi() % 100000;
		workshop_name_stepper_a = some_primes[rng.randi_range(0, some_primes.size() - 1)]
		workshop_name_stepper_b = some_primes[rng.randi_range(0, some_primes.size() - 1)]
		workshop_name_stepper_c = some_primes[rng.randi_range(0, some_primes.size() - 1)]
	var a : Array = ["Alpha", "Beta", "Gamma", "Delta", "Omega", "Primus", "Secundus", "Tertius", "Quartus"]
	var b : Array = [2, 3, 5,  7, 11, 13,  17, 19, 23,  29, 31, 37,  41, 43, 47, 53, 59, 61]
	var c : Array = ["Jekyll", "Strange", "No", "Moreau", "Moriarty", "Luthor", "Brundle", "Von Doom", "Loveless", "West", "Octavius", "Nemo"]
	workshop_name_index_a = (workshop_name_index_a + workshop_name_stepper_a) % a.size()
	workshop_name_index_b = (workshop_name_index_b + workshop_name_stepper_b) % b.size()
	workshop_name_index_c = (workshop_name_index_c + workshop_name_stepper_c) % c.size()
	var x = a[workshop_name_index_a]
	var y = b[workshop_name_index_b]
	var z = c[workshop_name_index_c]
	return "%s-%d-%s" % [x, y, z]

enum WorkshopTask {
	UNASSIGNED,
	MONEY,
	BLUEPRINT,
	GOLEMS,
}
# index: [task, minions]
var workshop_list : Dictionary = {}

func add_workshop() -> void:
	list_of_workshops_grid.show()
	var name_label : Label = Label.new()
	name_label.text = generate_workshop_name()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_of_workshops_grid.add_child(name_label)
	var minion_count_selector : SpinBox = SpinBox.new()
	minion_count_selector.prefix = "Minions allocated: "
	minion_count_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_of_workshops_grid.add_child(minion_count_selector)
	var option_button : OptionButton = OptionButton.new()
	option_button.add_item("(SELECT SOMETHING)", WorkshopTask.UNASSIGNED);
	option_button.set_item_tooltip(WorkshopTask.UNASSIGNED, "Select something for this workshop to build");
	option_button.add_item("Perform mindless labor", WorkshopTask.MONEY);
	option_button.set_item_tooltip(WorkshopTask.MONEY, "This will generate some money");
	option_button.add_item("Draft blueprints", WorkshopTask.BLUEPRINT);
	option_button.set_item_tooltip(WorkshopTask.BLUEPRINT, "Blueprints help you invent new things");
	option_button.select(0)
	option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_of_workshops_grid.add_child(option_button)
	option_button.set_item_disabled(0, true)
	var status_label : Label = Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.text = "10.0 quatloos/sec";
	list_of_workshops_grid.add_child(status_label)
	
	var child_count = list_of_workshops_grid.get_children().size();
	assert(child_count % 4 == 0);
	var workshop_index : int = (int)(child_count / 4.0);
	workshop_list[workshop_index] = [WorkshopTask.UNASSIGNED, 0]

	option_button.item_selected.connect(on_workshop_task_selected.bindv([workshop_index, option_button]))
	minion_count_selector.value_changed.connect(on_workshop_minion_count_changed.bindv([workshop_index, minion_count_selector]))

func on_workshop_task_selected(item_selected, workshop_index : int, option_button : OptionButton) -> void:
	var task : WorkshopTask = option_button.get_item_id(option_button.selected) as WorkshopTask
	print("Task changed to %s for workshop #%d (item selected = %s)" % [WorkshopTask.find_key(task), workshop_index, str(item_selected)])
	click_count += 1
	workshop_list[workshop_index][0] = task

func on_workshop_minion_count_changed(value : float, workshop_index : int, spin_box : SpinBox) -> void:
	print("Minion cound changed to %d for workshop #%d (value=%f)" % [spin_box.value, workshop_index, value])
	click_count += 1
	workshop_list[workshop_index][1] = spin_box.value as int

func _on_build_workshop_pressed() -> void:
	click_count += 1
	money -= cost_to_build_next_workshop
	cost_to_build_next_workshop = (int) (cost_to_build_next_workshop * cost_to_build_next_workshop_multiplier)
	add_workshop()
	update_workshop_button()
