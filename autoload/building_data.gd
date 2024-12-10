extends Node
# This script is designed to keep all the tower data - the mesh, scenes, 
# icons, and stats in a centralized location.

const DATA_PATH = "res://data/buildings.json"

enum Building {
	SIMPLE_TURRET,
	EXPLOSIVES,
	SNIPER,
	
	COAL_GENERATOR,
	SOLAR_PANEL,
	WIND_TURBINE,
	
	COAL_EXCAVATOR,
	LUMBER_HARVESTER,
	IRON_REFINERY,
	GOLD_REFINERY,
}

# These will, in the future, be moved to their respecitive building scripts,
# which will then request these stats from BuildingData, and set them accordingly.
# However, I just need it so the building placement indicator can show range
# right now, and don't have enough time for more than that.
class TowerStats:
	var attack_range: float


var _data: Dictionary : get = _get_data


func get_building_name(building: Building) -> String:
	return _data[_building_data_name(building)]["name"]


func get_building_category(building: Building) -> String:
	return _data[_building_data_name(building)]["category"]


func get_building_mesh(building: Building) -> Mesh:
	return load(_data[_building_data_name(building)]["mesh"])


func get_building_scene(building: Building) -> PackedScene:
	return load(_data[_building_data_name(building)]["scene"])


func get_tower_stats(building: Building) -> TowerStats:
	var building_data = _data[_building_data_name(building)]
	if not building_data.has("tower"):
		push_error(
			"Requested non-existant tower stats for "
			+ EnumNaming.enum_to_name(Building, building)
		)
		return null
	
	var tower_data = building_data["tower"]
	var tower_stats = TowerStats.new()
	tower_stats.attack_range = tower_data["range"]
	
	return tower_stats


# Consumable: amount (float)
func get_consumable_cost(building: Building) -> Dictionary:
	var result: Dictionary = {}
	
	var cost_entry = _data[_building_data_name(building)]["cost"]
	for consumable_name in cost_entry.keys():
		var consumable = _consumable_from_data_name(consumable_name)
		result[consumable] = cost_entry[consumable_name]
	
	return result


func _get_data() -> Dictionary:
	if _data:
		return _data
	
	var file = FileAccess.open(DATA_PATH, FileAccess.READ)
	var text: String = file.get_as_text()
	file.close()
	
	_data = JSON.parse_string(text)
	return _data


func _building_data_name(building: Building) -> String:
	return Building.keys()[building].to_lower()


func _consumable_from_data_name(data_name: String) -> ConsumablePool.Consumable:
	for consumable_name in ConsumablePool.Consumable.keys():
		if consumable_name.to_lower() == data_name:
			return ConsumablePool.Consumable[consumable_name]
	
	push_error("Unable to match " + data_name + " in known consumables.")
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	return -1
