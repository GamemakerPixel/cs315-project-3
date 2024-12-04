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
	IRON_EXCAVATOR,
}

var _data: Dictionary : get = _get_data


func get_building_name(building: Building) -> String:
	return _data[_building_data_name(building)]["name"]


func get_building_category(building: Building) -> String:
	return _data[_building_data_name(building)]["category"]


func get_building_mesh(building: Building) -> Mesh:
	return load(_data[_building_data_name(building)]["mesh"])


func get_building_scene(building: Building) -> PackedScene:
	return load(_data[_building_data_name(building)]["scene"])


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
