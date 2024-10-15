extends Resource

class_name Invention

enum InventionCondition {
	UNSET,
	WORKSHOP_COUNT,
	GOLEM_COUNT,
	GEAR_COUNT,
	ARTIFICIAL_MUSCLE_COUNT,
	GEAR_AND_MUSCLE_COUNT,
}

enum ActivationType {
	UNSET,
	UNLOCK_GOLEM,
	UNLOCK_GEARS,
	UNLOCK_ARTIFICIAL_MUSCLE,
}

@export var condition : InventionCondition = InventionCondition.UNSET
@export var condition_threshold : float = -1;
@export var blueprint_cost : int = -1;
@export var button_text : String = "unset"
@export var activation_type : ActivationType = ActivationType.UNSET
@export var activation_amount : int = 1
var condition_checker : Control = null

#func init(bname : String, cost : int, game : Control) -> void:
	#condition_checker = game
	#blueprint_cost = cost
	#button_text = bname
	
func describe() -> String:
	return "%s: %s >= %f && blueprints >= %d" % [button_text, InventionCondition.find_key(condition), condition_threshold, blueprint_cost]

func set_condition_checker(game : Control) -> void:
	condition_checker = game

func add_condition(cond : InventionCondition, amount : float) -> void:
	condition = cond
	condition_threshold = amount

func is_hidden() -> bool:
	var retVal : bool = condition_checker.is_invention_hidden(condition, condition_threshold)
	#condition_checker.db0("isHidden[%s, %s] = %s" % [button_text, InventionCondition.find_key(condition), str(retVal)])
	return retVal

var eta_text : String
func is_pending() -> bool:
	eta_text = condition_checker.is_invention_pending(condition, condition_threshold, blueprint_cost)
	return !eta_text.is_empty()

func get_eta_text() -> String:
	return eta_text

func get_button_text() -> String:
	return button_text

func activate() -> void:
	condition_checker.activate_invention(blueprint_cost, activation_type, activation_amount)
