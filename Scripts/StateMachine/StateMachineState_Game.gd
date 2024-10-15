extends StateMachineState

class_name SMS_Game

var click_count : int = 0 : set = set_click_count
var money : int = 0 : set = set_money
var blueprints : int = 0 : set = set_blueprints
var money_label : Label = null
var blueprints_attr : Label = null
var blueprints_value : Label = null
var idle_attr : Label = null
var idle_value : Label = null
var workshop_panel_label : Label = null
var main_button : Button = null
var unlock_button : Button = null
var augment_button : Button = null
var workshops_button : Button = null
var hire_minion_button : Button = null
var build_workshop_button : Button = null
var list_of_workshops_grid : GridContainer = null
var lab_grid : GridContainer = null
var werehouse_grid : GridContainer = null;
var augment_eta : Label = null
var oppossum_attr : Label = null
var oppossum_value : Label = null
var generate_money_tab : Control = null
var workshop_tab : Control = null
var lab_tab : Control = null
var tab_container : TabContainer = null
var	werehouse_tab : Control = null;

var main_button_stage : int = 0
var main_button_stages = {
	0: ["Tinker", 0, 1, "Put away your tinkering!\nBecome a coder."],
	1: ["Code", 10, 5, "Stop coding!\nTeach others your brilliance."],
	2: ["Mentor", 100, 10, "Bah, I'm thinking too small.\nLet me plan!"],
	3: ["Architect", 1000, 20, "Surely there is a market\nfor my brilliance!"],
	4: ["Patent", 10000, 50, "The fools don't understand me\nI will show them!"],
	5: ["Scheme", 100000, 100, "(((should not see this)))"],
}

var highlight_tab_texture : Texture2D = load("res://Art/redCircle.png")

var cost_to_hire_next_minion : int = 1000
var cost_to_nire_next_minion_multiplier : float = 2
var cost_to_build_next_workshop : int = 1000
var cost_to_build_next_workshop_multiplier : float = 3

var workshop_unlock_amount : int = 3500

var minion_money_delta : float = 600.0
var minion_blueprints_delta : float = 1 / 20.0
var minion_golems_delta : float = 1 / 20.0
var minion_gears_delta : float = 1 / 20.0
var minion_muscles_delta : float = 1 / 20.0

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
	LAB_TAB,
	WEREHOUSE_TAB,
}
enum TabAction {
	HIDE_TAB,
	SHOW_TAB,
	HIGHLIGHT_TAB,
	IS_HIDDEN,
}

var research_track_packed_scene : PackedScene = preload("res://Scenes/research_track.tscn")
	
@export var research_track_data_sets : Array[Resource] = []
@export var research_track : PackedScene = load("res://Scenes/research_track.tscn")

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
	
	#-------
	# Page Frame & Header
	#-------
	tab_container = find_tab_container("TabContainer");
	tab_container.tab_changed.connect(on_tab_changed)
	
	money_label = find_label("MoneyValue")
	
	oppossum_attr = find_label("OpposumAttr")
	oppossum_attr.hide()
	oppossum_value = find_label("OpposumValue")
	oppossum_value.hide()
	
	blueprints_attr = find_label("BlueprintAttr")
	blueprints_attr.hide()
	blueprints_value = find_label("BlueprintValue")
	blueprints_value.hide()
	
	idle_attr = find_label("IdleAttr")
	idle_attr.hide()
	idle_value = find_label("IdleValue")
	idle_value.hide()
	
	#-------
	# Money Page
	#-------

	generate_money_tab = find_control("Generate Money");
	generate_money_tab.show()
	change_tab(TabRef.GENERATE_MONEY_TAB, TabAction.SHOW_TAB)
	
	main_button = find_button("Button")
	main_button.text = main_button_stages[main_button_stage][0]
	
	unlock_button = find_button("UnlockButton")
	unlock_button.hide()

	augment_button = find_button("AugmentButton")
	augment_button.hide()
	augment_eta = find_label("AugmentETA")
	augment_eta.hide()

	#-------
	# Workshop Page
	#-------

	workshop_tab = find_control("Workshops");
	change_tab(TabRef.WORKSHOP_TAB, TabAction.HIDE_TAB)
	
	hire_minion_button = find_button("HireMinion")
	update_minion_button()
	build_workshop_button = find_button("BuildWorkshop")
	update_workshop_button()
	
	workshops_button = find_button("WorkshopsButton");
	workshops_button.hide()
	
	workshop_panel_label = find_label("WorkshopPanelLabel");
	workshop_panel_label.hide();
	list_of_workshops_grid = find_grid_container("ListOfWorkshops");
	list_of_workshops_grid.hide();

	#-------
	# Labrotory
	#-------
	
	lab_tab = find_control("Lab");
	change_tab(TabRef.LAB_TAB, TabAction.HIDE_TAB)
	lab_grid = find_grid_container("ListOfLabProjects");
	load_lab_grid()
	
	#-------
	# Werehouse
	#-------

	werehouse_tab = find_control("Werehouse");
	change_tab(TabRef.WEREHOUSE_TAB, TabAction.HIDE_TAB)
	werehouse_grid = find_grid_container("ListOfGoods");
	
	#-------
	# Other
	#-------

	money = 3300
	
	var it : Image = highlight_tab_texture.get_image();
	var imt : ImageTexture = ImageTexture.create_from_image(it)
	imt.set_size_override(Vector2i(8, 8))
	highlight_tab_texture = imt

func load_lab_grid() -> void:
	for rt_data : Resource in research_track_data_sets:
		print("load_lab_grid - processing %s" % [rt_data.resource_path]);
		var track : ResearchTrack = research_track.instantiate()
		track.init(self, rt_data)
		lab_grid.add_child(track)
	
func is_invention_hidden(condition : Invention.InventionCondition, _threshold : float) -> bool:
	match condition:
		Invention.InventionCondition.WORKSHOP_COUNT:
			return workshop_array.is_empty()
		Invention.InventionCondition.GOLEM_COUNT:
			return total_golems == 0
		Invention.InventionCondition.GEAR_COUNT:
			return werehouse_count(CraftedItemType.GEAR) == 0
		Invention.InventionCondition.ARTIFICIAL_MUSCLE_COUNT:
			return werehouse_count(CraftedItemType.ARTIFICIAL_MUSCLE) == 0
		Invention.InventionCondition.GEAR_AND_MUSCLE_COUNT:
			return werehouse_count(CraftedItemType.GEAR) == 0 || werehouse_count(CraftedItemType.ARTIFICIAL_MUSCLE) == 0
		_:
			assert(false, "Unknown invention condition: %s" % [Invention.InventionCondition.find_key(condition)])
			return false

var dbo0 : String
func db0(t : String) -> void:
	if t != dbo0:
		dbo0 = t;
		print(t)
var dbo1 : String
func db1(t : String) -> void:
	if t != dbo1:
		dbo1 = t;
		print(t)
var dbo2 : String
func db2(t : String) -> void:
	if t != dbo2:
		dbo2 = t;
		print(t)

func is_invention_pending(condition : Invention.InventionCondition, threshold : float, blueprints_needed: int) -> String:
	var blueprint_fraction : float = (blueprints as float) / (blueprints_needed as float)
	var cond_fraction : float = 0 
	match condition:
		Invention.InventionCondition.WORKSHOP_COUNT:
			cond_fraction = workshop_array.size() as float / threshold
		Invention.InventionCondition.GOLEM_COUNT:
			cond_fraction = total_golems as float / threshold
		Invention.InventionCondition.GEAR_COUNT:
			cond_fraction = werehouse_count(CraftedItemType.GEAR) as float / threshold
		Invention.InventionCondition.ARTIFICIAL_MUSCLE_COUNT:
			cond_fraction = werehouse_count(CraftedItemType.ARTIFICIAL_MUSCLE) as float / threshold
		Invention.InventionCondition.GEAR_AND_MUSCLE_COUNT:
			var g : float = werehouse_count(CraftedItemType.GEAR) as float / threshold
			var am : float = werehouse_count(CraftedItemType.ARTIFICIAL_MUSCLE) as float / threshold
			cond_fraction = (min(1.0, g) + min(1.0, am)) / 2.0
		_:
			assert(false, "Unknown invention condition: %s" % [Invention.InventionCondition.find_key(condition)])

	#db1("is_pending[%s]: b = %f, bn = %f, bf = %f, cf = %f" % [Invention.InventionCondition.find_key(condition), blueprints as float, blueprints_needed as float, blueprint_fraction, cond_fraction])
	if blueprint_fraction >= 1.0 && cond_fraction >= 1.0:
		return ""
	
	var percent : float = 50.0 * (min(1.0, blueprint_fraction) + min(1.0, cond_fraction))
	#db2("pending[%s]: %.1f" % [Invention.InventionCondition.find_key(condition), percent])
	return "%.1f%%" % [percent]

enum CraftedItemType {
	GEAR,
	ARTIFICIAL_MUSCLE,
}
var werehouse_holdings : Dictionary = {}
func werehouse_count(item_type : CraftedItemType) -> int:
	if werehouse_holdings.has(item_type):
		return werehouse_holdings[item_type] as int
	else:
		return 0

func werehouse_add(item_type: CraftedItemType, amount: int) -> void:
	if werehouse_holdings.has(item_type):
		werehouse_holdings[item_type] += amount
	else:
		werehouse_holdings[item_type] = amount
		change_tab(TabRef.WEREHOUSE_TAB, TabAction.SHOW_TAB)
		change_tab(TabRef.WEREHOUSE_TAB, TabAction.HIGHLIGHT_TAB)
	var it_name = CraftedItemType.find_key(item_type)
	var existing_child = werehouse_grid.find_child(it_name)
	if existing_child == null:
		var mc = MarginContainer.new()
		mc.name = it_name
		var l = Label.new()
		l.text = it_name
		mc.add_child(l)
		var a = Label.new()
		a.text = str(werehouse_holdings[item_type])
		mc.add_child(a)
		werehouse_grid.add_child(mc)
	else:
		existing_child.get_child(1).text = str(werehouse_holdings[item_type])

func get_tab_index(tab: TabRef) -> int:
	var idx : int = -1;
	match tab:
		TabRef.GENERATE_MONEY_TAB:
			idx = tab_container.get_tab_idx_from_control(generate_money_tab)
		TabRef.WORKSHOP_TAB:
			idx = tab_container.get_tab_idx_from_control(workshop_tab)
		TabRef.LAB_TAB:
			idx = tab_container.get_tab_idx_from_control(lab_tab)
		TabRef.WEREHOUSE_TAB:
			idx = tab_container.get_tab_idx_from_control(werehouse_tab)
	assert(idx != -1, "Did not find tab %s in %s" % [TabRef.find_key(tab), tab_container.name])
	return idx

func change_tab(tab : TabRef, change : TabAction) -> void:
	var idx : int = get_tab_index(tab)
	match change:
		TabAction.HIDE_TAB:
			tab_container.set_tab_hidden(idx, true)
			print("Hiding tab %s" % tab_container.get_tab_title(idx))
		TabAction.SHOW_TAB:
			tab_container.set_tab_hidden(idx, false)
			print("Showing tab %s" % tab_container.get_tab_title(idx))
		TabAction.HIGHLIGHT_TAB:
			if !tab_container.is_tab_disabled(idx):
				if tab_container.current_tab != idx:
					tab_container.get_tab_bar().set_tab_icon(idx, highlight_tab_texture)
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
		oppossum_value.text = "%s/sec" % money_string(augment_amount * main_button_stages[main_button_stage][2])
		if augment_remainder >= 1.0:
			money += (int)(augment_remainder)
			augment_remainder -= floor(augment_remainder)
	process_workshops(delta)

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
		money_label.text = money_string(money)
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

func highlight_lab() -> void:
	change_tab(TabRef.LAB_TAB, TabAction.HIGHLIGHT_TAB)

func set_blueprints(new_value : int) -> void:
	blueprints = new_value
	blueprints_value.text = str(blueprints)
	if blueprints == 0:
		return
	if blueprints_attr.visible == false:
		blueprints_value.show()
		blueprints_attr.show()
		change_tab(TabRef.LAB_TAB, TabAction.SHOW_TAB)
		change_tab(TabRef.LAB_TAB, TabAction.HIGHLIGHT_TAB)

var workshop_types_unlocked : Array[Workshop.WorkshopTask] = []
var workshop_types : Dictionary = {
	Invention.ActivationType.UNLOCK_GOLEM: [false, Workshop.WorkshopTask.GOLEMS, "Craft Robots", "Robots will work with minions in workshops"],
	Invention.ActivationType.UNLOCK_GEARS: [false, Workshop.WorkshopTask.GEARS, "Craft Gears", "Gears will help you craft other things"],
	Invention.ActivationType.UNLOCK_ARTIFICIAL_MUSCLE: [false, Workshop.WorkshopTask.ARTIFICIAL_MUSCLE, "Craft Synthetic Muscle", "Synthetic muscle will help you craft other things" ],
}

func add_text_and_tooltip_to_id(option_button : OptionButton, task : Workshop.WorkshopTask, item_name : String, item_tooltip : String) -> int:
	option_button.add_item(item_name, task);
	var index : int = option_button.get_item_index(task)
	option_button.set_item_tooltip(index, item_tooltip);
	return index

func populate_workshop_option_button(option_button : OptionButton) -> void:
	if option_button.get_item_index(Workshop.WorkshopTask.MONEY) == -1:
		var index = add_text_and_tooltip_to_id(option_button, Workshop.WorkshopTask.MONEY, "Perform mindless labor", "This will generate some money")
		#option_button.add_item("Perform mindless labor", Workshop.WorkshopTask.MONEY);
		#option_button.set_item_tooltip(Workshop.WorkshopTask.MONEY, "This will generate some money");
		option_button.select(index)
	if option_button.get_item_index(Workshop.WorkshopTask.BLUEPRINT) == -1:
		add_text_and_tooltip_to_id(option_button, Workshop.WorkshopTask.BLUEPRINT, "Draft blueprints",  "Blueprints help you invent new things")
	for key in workshop_types.keys():
		var data = workshop_types[key]
		if data[0]:
			if option_button.get_item_index(data[1]) == -1:
				add_text_and_tooltip_to_id(option_button, data[1], data[2], data[3])

func activate_invention(blueprint_cost : int, activation_type : Invention.ActivationType, _activation_amount : int) -> void:
	assert(blueprints >= blueprint_cost)
	blueprints -= blueprint_cost
	if workshop_types.keys().has(activation_type):
		if workshop_types[activation_type][0] == false:
			workshop_types[activation_type][0] = true
			for workshop in workshop_array:
				populate_workshop_option_button(workshop.option_button)
			change_tab(TabRef.WORKSHOP_TAB, TabAction.HIGHLIGHT_TAB)
	else:
		assert(false, "Can't activate invention for %s - no matching workshop" % [Invention.ActivationType.find_key(activation_type)])

func money_string(dollars : float) -> String:
	if dollars < 100:
		return "$%.2f" % dollars
	
	if dollars < 1000:
		return "$%.0f" % dollars
	
	if dollars < 1000000:
		return "%.1fK" % (dollars / 1000.0)

	if dollars < 1000000000:
		return "%.1fM" % (dollars / 1000000.0)

	return "%.1fB" % (dollars / 1000000000.0)

func update_minion_button() -> void:
	hire_minion_button.text = "Hire Minion\n%s" % money_string(cost_to_hire_next_minion)
	if money < cost_to_hire_next_minion:
		hire_minion_button.set_disabled(true)
	elif hire_minion_button.is_disabled():
		change_tab(TabRef.WORKSHOP_TAB, TabAction.HIGHLIGHT_TAB)
		hire_minion_button.set_disabled(false)

func update_workshop_button() -> void:
	build_workshop_button.text = "Build Workshop\n%s" % money_string(cost_to_build_next_workshop)
	if money < cost_to_build_next_workshop:
		build_workshop_button.set_disabled(true)
	elif build_workshop_button.is_disabled():
		change_tab(TabRef.WORKSHOP_TAB, TabAction.HIGHLIGHT_TAB)
		build_workshop_button.set_disabled(false)

func set_click_count(new_value : int) -> void:
	click_count = new_value
	update_augment_button_fraction(1.0, 0)

func on_tab_changed(index : int) -> void:
	tab_container.get_tab_bar().set_tab_icon(index, null)

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

var total_golems : int = 0
var total_minions : int = 0

func increase_golems() -> void:
	total_golems += 1
	update_minion_button()
	update_all_workshops()

func _on_hire_minion_pressed() -> void:
	click_count += 1
	money -= cost_to_hire_next_minion
	total_minions += 1
	cost_to_hire_next_minion = (int) (cost_to_hire_next_minion * cost_to_nire_next_minion_multiplier)
	update_minion_button()
	update_all_workshops()

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
	
# index: [task, minions]
var workshop_array : Array[Workshop] = []

func get_available_minions() -> int:
	var retVal : int = total_minions + total_golems
	for workshop in workshop_array:
		retVal -= workshop.minion_count
	return retVal

func process_workshops(delta: float) -> void:
	for workshop in workshop_array:
		workshop.process(delta)

func update_all_workshops() -> void:
	var available_minions : int = get_available_minions()
	if available_minions > 0 && idle_attr.hidden:
		idle_attr.show()
		idle_value.show()
	idle_value.text = str(available_minions)
	for workshop in workshop_array:
		workshop.update_available_minions(available_minions)

func add_workshop() -> void:
	if workshop_panel_label.hidden:
		workshop_panel_label.show()
		list_of_workshops_grid.show()
	var workshop : Workshop = Workshop.new()
	var workshop_name : String = generate_workshop_name()
	add_child(workshop)
	workshop.init(workshop_name, list_of_workshops_grid, workshop_array, get_available_minions(), self)

func _on_build_workshop_pressed() -> void:
	click_count += 1
	money -= cost_to_build_next_workshop
	cost_to_build_next_workshop = (int) (cost_to_build_next_workshop * cost_to_build_next_workshop_multiplier)
	add_workshop()
	update_workshop_button()
