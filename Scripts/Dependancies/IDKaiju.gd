extends InventionDependancy

class_name IDKaiju

@export var gear_count : int = 1
@export var sensor_count : int = 1
@export var muscle_count : int = 1

func describe(game : SMS_Game) -> String:
	var retVal = "Gear > %d, Sensor > %d, Muscle > %d, Full Marsupial" % [gear_count, sensor_count, muscle_count];
	if blueprint_cost > 0:
		retVal += (", %d blueprints" % blueprint_cost)
	if money_cost > 0:
		retVal += (", %s" % game.money_string(money_cost))
	return retVal

func is_invention_hidden(game : SMS_Game) -> bool:
	if game.has_been_invented(SMS_Game.CraftedItemType.GEAR) == false:
		return true
	if game.has_been_invented(SMS_Game.CraftedItemType.ARTIFICIAL_MUSCLE) == false:
		return true
	if game.has_been_invented(SMS_Game.CraftedItemType.SENSOR_PACK) == false:
		return true
	return game.augment_button_stage == 0

func is_invention_pending(game : SMS_Game) -> Array[String]:
	var a_fraction : float = game.measure_marsupial_augmentation(true)
	var g_fraction : float = min(1.0, game.warehouse_count(SMS_Game.CraftedItemType.GEAR) as float / gear_count as float)
	var s_fraction : float = min(1.0, game.warehouse_count(SMS_Game.CraftedItemType.SENSOR_PACK) as float / sensor_count as float)
	var m_fraction : float = min(1.0, game.warehouse_count(SMS_Game.CraftedItemType.ARTIFICIAL_MUSCLE) as float / muscle_count as float)
	var fraction : float = g_fraction + s_fraction + m_fraction + a_fraction
	var needs : Array = [[g_fraction, "Gears"], [s_fraction, "Sensor Packs"], [m_fraction, "Synthetic Muscles"], [a_fraction, "Marsupial Advancement"]]
	var total : float = 4.0
	if blueprint_cost > 0:
		total += 1.0
		var b_fraction : float = min(1.0, game.blueprints as float / blueprint_cost as float);
		needs.append([b_fraction, "Blueprints"])
		fraction += b_fraction
	if money_cost > 0:
		total += 1.0
		var money_fraction : float = min(1.0, game.money as float / money_cost as float);
		needs.append([money_fraction, "Money"])
		fraction += money_fraction
	
	if fraction == total:
		return ["", ""]
		
	needs.sort_custom(sort_needs)
		
	#print("%s=%f  %s=%f" % [needs[0][1], needs[0][0], needs[1][1], needs[1][0]])
	return ["%.1f%%" % [fraction * 100.0 / total], needs[0][1]]

func pay_for_activation(game : SMS_Game) -> void:
	pay_money(game)
	pay_blueprints(game)
	game.warehouse_add(SMS_Game.CraftedItemType.GEAR, 0 - gear_count)
	game.warehouse_add(SMS_Game.CraftedItemType.SENSOR_PACK, 0 - sensor_count)
	game.warehouse_add(SMS_Game.CraftedItemType.ARTIFICIAL_MUSCLE, 0 - muscle_count)
