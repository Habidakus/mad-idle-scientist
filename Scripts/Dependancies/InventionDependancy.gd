extends Resource

class_name InventionDependancy

@export var blueprint_cost : int = 0
@export var money_cost : int = 0

func describe(_game : SMS_Game) -> String:
	return "UNDEFINED"

func is_invention_hidden(_game : SMS_Game) -> bool:
	assert(false, "Not Implemented")
	return false

func is_invention_pending(_game : SMS_Game) -> Array[String]:
	assert(false, "Not Implemented")
	return ["", ""]

func pay_for_activation(_game : SMS_Game) -> void:
	assert(false, "Not Implemented")
	pass

# ------------- useful funcs -------------------------

func sort_needs(a, b) -> bool:
	return a[0] < b[0]

func pay_money(game : SMS_Game) -> void:
	if money_cost > 0:
		game.money -= money_cost

func pay_blueprints(game : SMS_Game) -> void:
	if blueprint_cost > 0:
		game.blueprints -= blueprint_cost
