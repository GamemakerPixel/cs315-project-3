extends Control

signal building_selected(building: BuildingData.Building)

const COST_PREFIX = "Cost: "
const FREE_COST_TEXT = "Free"
const COST_DELIMITER = ", "
const INDIVIDUAL_COST_DELIMITER = " "

var building: BuildingData.Building : set = _set_building


func _ready() -> void:
	$Button.pressed.connect(_on_pressed)


func _set_building(new_building: BuildingData.Building) -> void:
	building = new_building
	$Button.text = BuildingData.get_building_name(building)
	$Cost.text = _create_cost_text()


func _create_cost_text() -> String:
	var cost = BuildingData.get_consumable_cost(building)
	
	var individual_entries: Array[String] = []
	for consumable in cost.keys():
		var value: float = cost[consumable]
		individual_entries.append(
			str(value) + INDIVIDUAL_COST_DELIMITER
			+ EnumNaming.enum_to_name(ConsumablePool.Consumable, consumable)
		)
	
	return COST_PREFIX + COST_DELIMITER.join(individual_entries)


func _on_pressed() -> void:
	building_selected.emit(building)
