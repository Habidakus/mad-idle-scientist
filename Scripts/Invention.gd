extends Resource

class_name Invention

enum ActivationType {
	UNSET,
	UNLOCK_ROBOT,
	UNLOCK_GEARS,
	UNLOCK_ARTIFICIAL_MUSCLE,
	UNLOCK_SENSORS, 
	UNLOCK_WORKSHOP_UPGRADE, # x3
	UNLOCK_MARSUPIAL_GROWTH, # x4
	UNLOCK_INVESTMENT_BANKING, # x4
	UNLOCK_KAIJU,
}

@export var dependancy : InventionDependancy;
@export var button_text : String = "unset"
@export var activation_type : ActivationType = ActivationType.UNSET
@export var activation_amount : int = 1
var condition_checker : SMS_Game = null
	
func describe() -> String:
	#return "%s: %s >= %f && blueprints >= %d" % [button_text, InventionCondition.find_key(condition), condition_threshold, blueprint_cost]
	return "%s: %s" % [button_text, dependancy.describe(condition_checker)]

func set_condition_checker(game : Control) -> void:
	condition_checker = game

func is_hidden() -> bool:
	var retVal : bool = dependancy.is_invention_hidden(condition_checker)
	#condition_checker.db0("isHidden[%s, %s] = %s" % [button_text, InventionCondition.find_key(condition), str(retVal)])
	return retVal

var eta_text : String
var dependancy_text : String
func is_pending() -> bool:
	var result = dependancy.is_invention_pending(condition_checker)
	eta_text = result[0]
	dependancy_text = result[1]
	return !eta_text.is_empty()

func get_eta_text() -> String:
	return eta_text
func get_needs_text() -> String:
	return dependancy_text

func get_button_text() -> String:
	return button_text

func activate() -> void:
	dependancy.pay_for_activation(condition_checker)
	condition_checker.activate_invention(activation_type)
