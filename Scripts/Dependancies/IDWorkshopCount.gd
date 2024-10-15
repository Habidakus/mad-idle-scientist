extends InventionDependancy

class_name IDWorkshopCount

@export var workshop_count : int = 1

func describe(game : SMS_Game) -> String:
	var retVal = "WorkshopCount > %d" % workshop_count;
	if blueprint_cost > 0:
		retVal += (", %d blueprints" % blueprint_cost)
	if money_cost > 0:
		retVal += (", %s" % game.money_string(money_cost))
	return retVal

func is_invention_hidden(game : SMS_Game) -> bool:
	return game.workshop_array.is_empty()

func is_invention_pending(game : SMS_Game) -> Array[String]:
	var fraction : float = min(1.0, game.workshop_array.size() as float / workshop_count as float)
	var needs : Array = [[fraction, "Workshops"]]
	var total : float = 1.0
	if blueprint_cost > 0:
		total += 1.0
		var b_fraction : float = min(1.0, game.blueprints as float / blueprint_cost as float)
		needs.append([b_fraction, "Blueprints"])
		fraction += b_fraction
	if money_cost > 0:
		total += 1.0
		var m_fraction : float = min(1.0, game.money as float / money_cost as float)
		needs.append([m_fraction, "Money"])
		fraction += m_fraction
	
	if fraction == total:
		return ["", ""]
		
	needs.sort_custom(sort_needs)
	return ["%.1f%%" % [fraction * 100.0 / total], needs[0][1]]

func pay_for_activation(game : SMS_Game) -> void:
	pay_money(game)
	pay_blueprints(game)
