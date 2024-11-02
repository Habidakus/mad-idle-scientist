extends Node

class_name Workshop

enum WorkshopTask {
	MONEY,
	BLUEPRINT,
	ROBOTS,
	GEARS,
	ARTIFICIAL_MUSCLE,
	SENSOR_PACKS,
	KAIJU,
}

var task : WorkshopTask = WorkshopTask.MONEY
var minion_count : int = 0

var highlight_particle_scene : PackedScene = preload("res://Scenes/highlight.tscn")

var name_label : Label = Label.new()

var minion_increase_button : Button = Button.new()
var minion_decrease_button : Button = Button.new()
var minion_label : Label = Label.new()
var minion_container : HBoxContainer = HBoxContainer.new()

var style_box : StyleBoxLine = StyleBoxLine.new()
var option_button : OptionButton = OptionButton.new()
var status_label : Label = Label.new()
var highlight_vfx : Control = null

var partial_money : float = 0
var partial_blueprints : float = 0
var partial_robots : float = 0
var partial_gears : float = 0
var partial_muscles : float = 0
var partial_sensor_pack : float = 0

func get_workshop_name() -> String:
	return name_label.text

func init(workshop_name : String, grid_container : GridContainer, workshop_list : Array[Workshop], available_minions : int, game : SMS_Game) -> void:
	name_label.text = workshop_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.add_child(name_label)
	
	highlight_vfx = highlight_particle_scene.instantiate()
	#highlight_vfx.global_position = option_button.global_position + option_button.size / 2.0
	highlight_vfx.hide()
	option_button.add_child(highlight_vfx)

	minion_label.text = "Workers: 0"
	minion_decrease_button.text = "-";
	minion_increase_button.text = "+";
	minion_increase_button.set_disabled(available_minions == 0)
	minion_decrease_button.set_disabled(minion_count == 0)
	minion_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	minion_container.add_child(minion_label)
	minion_container.add_child(minion_decrease_button)
	minion_container.add_child(minion_increase_button)
	minion_container.alignment = BoxContainer.ALIGNMENT_CENTER
	grid_container.add_child(minion_container)
	
	style_box.color = Color.RED
	style_box.vertical = true
	
	game.populate_workshop_option_button(option_button)
	highlight_option_button(game.should_workshop_task_be_highlighted())
	option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	grid_container.add_child(option_button)
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.add_child(status_label)
	
	var child_count = grid_container.get_children().size();
	assert(child_count % 4 == 0);
	workshop_list.append(self)

	option_button.button_down.connect(on_button_down)
	option_button.item_selected.connect(on_workshop_task_selected)
	minion_decrease_button.pressed.connect(on_workshop_minion_count_decrease)
	minion_increase_button.pressed.connect(on_workshop_minion_count_increase)
	
	update_status()

func process(delta : float) -> void:
	var game : SMS_Game = get_parent();
	var minion_strength : float = sqrt(minion_count) * game.workshop_efficiency
	highlight_vfx.position = option_button.size / 2.0
	match task:
		WorkshopTask.MONEY:
			partial_money += game.minion_money_delta * minion_strength * delta
			if partial_money >= 1.0:
				var earned_money : int = floor(partial_money) as int
				partial_money -= earned_money
				game.money += earned_money
		WorkshopTask.ROBOTS:
			if game.warehouse_count(SMS_Game.CraftedItemType.GEAR) > 0 && game.warehouse_count(SMS_Game.CraftedItemType.ARTIFICIAL_MUSCLE) > 0:
				partial_robots += game.minion_robots_delta * minion_strength * delta
				while partial_robots >= 1.0:
					game.warehouse_add(SMS_Game.CraftedItemType.GEAR, -1)
					game.warehouse_add(SMS_Game.CraftedItemType.ARTIFICIAL_MUSCLE, -1)
					partial_robots -= 1
					game.increase_robots()
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
				game.warehouse_add(SMS_Game.CraftedItemType.GEAR, earned_gears)
		WorkshopTask.ARTIFICIAL_MUSCLE:
			partial_muscles += game.minion_muscles_delta * minion_strength * delta
			if partial_muscles >= 1.0:
				var earned_muscles : int = floor(partial_muscles) as int
				partial_muscles -= earned_muscles
				game.warehouse_add(SMS_Game.CraftedItemType.ARTIFICIAL_MUSCLE, earned_muscles)
		WorkshopTask.SENSOR_PACKS:
			partial_sensor_pack += game.minion_sensor_pack_delta * minion_strength * delta
			if partial_sensor_pack >= 1.0:
				var earned_sensor_pack : int = floor(partial_sensor_pack) as int
				partial_sensor_pack -= earned_sensor_pack
				game.warehouse_add(SMS_Game.CraftedItemType.SENSOR_PACK, earned_sensor_pack)
		WorkshopTask.KAIJU:
			game.add_kaiju_parts(game.minion_kaiju_delta * minion_strength * delta)
		_:
			assert(false, "Workshops don't know how to process task %s yet" % [WorkshopTask.find_key(task)])

func on_button_down() -> void:
	if option_button.has_theme_stylebox_override("normal"):
		var game : SMS_Game = get_parent();
		game.on_workshop_tasks_seen()

func highlight_option_button(enable: bool) -> void:
	if enable:
		option_button.add_theme_stylebox_override("normal", style_box)
		highlight_vfx.show()
	else:
		option_button.remove_theme_stylebox_override("normal")
		highlight_vfx.hide()

func update_status() -> void:
	if minion_count == 0:
		status_label.text = "NO WORKERS ASSIGNED"
		return

	var game : SMS_Game = get_parent()
	var minion_strength : float = sqrt(minion_count) * game.workshop_efficiency
	match task:
		WorkshopTask.MONEY:
			var dollars_per_second : float = game.minion_money_delta * minion_strength
			status_label.text = "%s/sec" % game.money_string(dollars_per_second);
		WorkshopTask.BLUEPRINT:
			var blueprints_per_second : float = game.minion_blueprints_delta * minion_strength
			status_label.text = "%.2f blueprints/sec" % blueprints_per_second;
		WorkshopTask.ROBOTS:
			if game.warehouse_count(SMS_Game.CraftedItemType.GEAR) == 0:
				status_label.text = "Stalled - no gears"
			elif game.warehouse_count(SMS_Game.CraftedItemType.ARTIFICIAL_MUSCLE) == 0:
				status_label.text = "Stalled - no synthetic muscle"
			else:
				var robots_per_second : float = game.minion_robots_delta * minion_strength
				status_label.text = "%.2f robots/sec" % robots_per_second;
		WorkshopTask.GEARS:
			var gears_per_second : float = game.minion_gears_delta * minion_strength
			status_label.text = "%.2f gears/sec" % gears_per_second;
		WorkshopTask.ARTIFICIAL_MUSCLE:
			var muscles_per_second : float = game.minion_muscles_delta * minion_strength
			status_label.text = "%.2f synmusc/sec" % muscles_per_second;
		WorkshopTask.SENSOR_PACKS:
			var sensors_per_second : float = game.minion_sensor_pack_delta * minion_strength
			status_label.text = "%.2f packs/sec" % sensors_per_second;
		WorkshopTask.KAIJU:
			status_label.text = "Building Kaiju"
		_:
			status_label.text = "TASK UNKNOWN"

func on_workshop_task_selected(index : int) -> void:
	var assign_task : WorkshopTask = option_button.get_item_id(index) as WorkshopTask
	var parent = get_parent() as SMS_Game
	parent.inc_click_count(false)
	if Input.is_key_pressed(KEY_SHIFT):
		parent.set_all_workshop_tasks(assign_task)
	else:
		set_task(assign_task)

func set_task(assign_task : WorkshopTask) -> void:
	task = assign_task
	option_button.remove_theme_stylebox_override("normal")
	option_button.selected = option_button.get_item_index(assign_task as int)
	update_status()

func on_workshop_minion_count_increase() -> void:
	var parent = get_parent() as SMS_Game
	# Holding down shift will change the count by a factor of 10
	var available_minions : int = parent.get_available_minions()
	if Input.is_key_pressed(KEY_SHIFT):
		minion_count += min(10, available_minions)
	else:
		minion_count += min(1, available_minions)
	minion_label.text = "Workers: %d" % minion_count
	parent.inc_click_count(false)
	parent.update_all_workshop_minions()
	update_status()

func on_workshop_minion_count_decrease() -> void:
	assert(minion_count > 0)
	# Holding down shift will change the count by a factor of 10
	if Input.is_key_pressed(KEY_SHIFT):
		minion_count = max(0, minion_count - 10)
	else:
		minion_count = max(0, minion_count - 1)
	minion_label.text = "Workers: %d" % minion_count
	var parent = get_parent() as SMS_Game
	parent.inc_click_count(false)
	parent.update_all_workshop_minions()
	update_status()

func update_available_minions(available_minions : int) -> void:
	minion_increase_button.set_disabled(available_minions == 0)
	minion_decrease_button.set_disabled(minion_count == 0)
	#minion_count_selector.max_value = available_minions + minion_count
	#print("Workshop %s max minions set to %d" % [get_workshop_name(), minion_count_selector.max_value])
