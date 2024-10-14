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

func init(workshop_name : String, grid_container : GridContainer, workshop_list : Array[Workshop], available_minions : int, game : Control) -> void:
	name_label.text = workshop_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.add_child(name_label)
	minion_count_selector.prefix = "Minions allocated: "
	minion_count_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	minion_count_selector.max_value = available_minions
	grid_container.add_child(minion_count_selector)
	game.populate_workshop_option_button(option_button)
	#option_button.add_item("Perform mindless labor", WorkshopTask.MONEY);
	#option_button.set_item_tooltip(WorkshopTask.MONEY, "This will generate some money");
	#option_button.add_item("Draft blueprints", WorkshopTask.BLUEPRINT);
	#option_button.set_item_tooltip(WorkshopTask.BLUEPRINT, "Blueprints help you invent new things");
	#option_button.select(0)
	option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#option_button.set_item_disabled(0, true)
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
func process(delta : float) -> void:
	var minion_strength : float = sqrt(minion_count)
	match task:
		WorkshopTask.MONEY:
			partial_money += get_parent().minion_money_delta * minion_strength * delta
			if partial_money >= 1.0:
				var earned_money : int = floor(partial_money) as int
				partial_money -= earned_money
				get_parent().money += earned_money
		WorkshopTask.BLUEPRINT:
			partial_blueprints += get_parent().minion_blueprints_delta * minion_strength * delta
			if partial_blueprints >= 1.0:
				var earned_blueprints : int = floor(partial_blueprints) as int
				partial_blueprints -= earned_blueprints
				get_parent().blueprints += earned_blueprints
		_:
			assert(false, "Workshops don't know how to process task %s yet" % [WorkshopTask.find_key(task)])

func update_status() -> void:
	var minion_strength : float = sqrt(minion_count)
	match task:
		WorkshopTask.MONEY:
			var dollars_per_second : float = get_parent().minion_money_delta * minion_strength
			status_label.text = "$%.0f/sec" % dollars_per_second;
		WorkshopTask.BLUEPRINT:
			var blueprints_per_second : float = get_parent().minion_blueprints_delta * minion_strength
			status_label.text = "%.2f blueprints/sec" % blueprints_per_second;
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
