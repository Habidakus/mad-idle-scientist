extends Node

class_name Workshop

enum WorkshopTask {
	MONEY,
	BLUEPRINT,
	GOLEMS,
	GEARS,
	ARTIFICIAL_MUSCLE,
}

var task : WorkshopTask = WorkshopTask.MONEY
var minion_count : int = 0

var name_label : Label = Label.new()
var minion_count_selector : SpinBox = SpinBox.new()
var option_button : OptionButton = OptionButton.new()
var status_label : Label = Label.new()

func get_workshop_name() -> String:
	return name_label.text

func init(workshop_name : String, grid_container : GridContainer, workshop_list : Array[Workshop], available_minions : int, game : SMS_Game) -> void:
	name_label.text = workshop_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.add_child(name_label)
	minion_count_selector.prefix = "Minions allocated: "
	minion_count_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	minion_count_selector.max_value = available_minions
	grid_container.add_child(minion_count_selector)
	game.populate_workshop_option_button(option_button)
	option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.add_child(option_button)
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.add_child(status_label)
	
	var child_count = grid_container.get_children().size();
	assert(child_count % 4 == 0);
	workshop_list.append(self)

	option_button.item_selected.connect(on_workshop_task_selected)
	minion_count_selector.value_changed.connect(on_workshop_minion_count_changed)
	
	update_status()

var partial_money : float = 0
var partial_blueprints : float = 0
var partial_golems : float = 0
var partial_gears : float = 0
var partial_muscles : float = 0
func process(delta : float) -> void:
	var minion_strength : float = sqrt(minion_count)
	var game : SMS_Game = get_parent();
	match task:
		WorkshopTask.MONEY:
			partial_money += game.minion_money_delta * minion_strength * delta
			if partial_money >= 1.0:
				var earned_money : int = floor(partial_money) as int
				partial_money -= earned_money
				game.money += earned_money
		WorkshopTask.GOLEMS:
			if game.werehouse_count(SMS_Game.CraftedItemType.GEAR) > 0 && game.werehouse_count(SMS_Game.CraftedItemType.ARTIFICIAL_MUSCLE) > 0:
				partial_golems += game.minion_golems_delta * minion_strength * delta
				while partial_golems >= 1.0:
					game.werehouse_add(SMS_Game.CraftedItemType.GEAR, -1)
					game.werehouse_add(SMS_Game.CraftedItemType.ARTIFICIAL_MUSCLE, -1)
					partial_golems -= 1
					game.increase_golems()
		WorkshopTask.BLUEPRINT:
			partial_blueprints += game.minion_blueprints_delta * minion_strength * delta
			if partial_blueprints >= 1.0:
				var earned_blueprints : int = floor(partial_blueprints) as int
				partial_blueprints -= earned_blueprints
				game.blueprints += earned_blueprints
		WorkshopTask.GEARS:
			partial_gears += game.minion_gears_delta * minion_strength * delta
			if partial_gears >= 1.0:
				var earned_gears : int = floor(partial_gears) as int
				partial_gears -= earned_gears
				game.werehouse_add(SMS_Game.CraftedItemType.GEAR, earned_gears)
		WorkshopTask.ARTIFICIAL_MUSCLE:
			partial_muscles += game.minion_muscles_delta * minion_strength * delta
			if partial_muscles >= 1.0:
				var earned_muscles : int = floor(partial_muscles) as int
				partial_muscles -= earned_muscles
				game.werehouse_add(SMS_Game.CraftedItemType.ARTIFICIAL_MUSCLE, earned_muscles)
		_:
			assert(false, "Workshops don't know how to process task %s yet" % [WorkshopTask.find_key(task)])

func update_status() -> void:
	if minion_count == 0:
		status_label.text = "NO WORKERS ASSIGNED"
		return

	var minion_strength : float = sqrt(minion_count)
	var game : SMS_Game = get_parent()
	match task:
		WorkshopTask.MONEY:
			var dollars_per_second : float = game.minion_money_delta * minion_strength
			status_label.text = "%s/sec" % game.money_string(dollars_per_second);
		WorkshopTask.BLUEPRINT:
			var blueprints_per_second : float = game.minion_blueprints_delta * minion_strength
			status_label.text = "%.2f blueprints/sec" % blueprints_per_second;
		WorkshopTask.GOLEMS:
			if game.werehouse_count(SMS_Game.CraftedItemType.GEAR) == 0:
				status_label.text = "Stalled - no gears"
			elif game.werehouse_count(SMS_Game.CraftedItemType.ARTIFICIAL_MUSCLE) == 0:
				status_label.text = "Stalled - no synthetic muscle"
			else:
				var golems_per_second : float = game.minion_golems_delta * minion_strength
				status_label.text = "%.2f golems/sec" % golems_per_second;
		WorkshopTask.GEARS:
			var gears_per_second : float = game.minion_gears_delta * minion_strength
			status_label.text = "%.2f gears/sec" % gears_per_second;
		WorkshopTask.ARTIFICIAL_MUSCLE:
			var muscles_per_second : float = game.minion_muscles_delta * minion_strength
			status_label.text = "%.2f synmusc/sec" % muscles_per_second;
		_:
			status_label.text = "TASK UNKNOWN"

func on_workshop_task_selected(index : int) -> void:
	task = option_button.get_item_id(index) as WorkshopTask
	#print("Workshop %s task changed to %s (index = %s)" % [get_workshop_name(), WorkshopTask.find_key(task), str(index)])
	option_button.selected = option_button.get_item_index(task as int)
	get_parent().click_count += 1
	update_status()

func on_workshop_minion_count_changed(value : float) -> void:
	minion_count = value as int
	#print("Workshop %s minion count changed to %d (value = %f)" % [get_workshop_name(), minion_count, value])
	var parent = get_parent()
	parent.click_count += 1
	parent.update_all_workshops()
	update_status()

func update_available_minions(available_minions : int) -> void:
	minion_count_selector.max_value = available_minions + minion_count
	#print("Workshop %s max minions set to %d" % [get_workshop_name(), minion_count_selector.max_value])
