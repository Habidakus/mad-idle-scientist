extends Node

class_name Invention

enum InventionCondition {
	UNSET,
	WORKSHOP_COUNT,
	GOLEM_COUNT,
}
var condition : InventionCondition = InventionCondition.UNSET
var condition_threshold : float = -1;
var blueprint_cost : int = -1;
var button_text : String = "unset"
var condition_checker : Control = null

func init(bname : String, cost : int, game : Control) -> void:
	condition_checker = game
	blueprint_cost = cost
	button_text = bname

func add_condition(cond : InventionCondition, amount : float) -> void:
	condition = cond
	condition_threshold = amount

func is_hidden() -> bool:
	return condition_checker.is_invention_hidden(condition, condition_threshold)

var eta_text : String
func is_pending() -> bool:
	eta_text = condition_checker.is_invention_pending(condition, condition_threshold, blueprint_cost)
	return !eta_text.is_empty()

func get_eta_text() -> String:
	return eta_text

func get_button_text() -> String:
	return button_text

func activate() -> void:
	print("TODO: Need to activate \"%s\"" % button_text)
