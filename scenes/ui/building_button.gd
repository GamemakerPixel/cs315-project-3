extends Button

signal building_selected(building: BuildingData.Building)

var building: BuildingData.Building : set = _set_building


func _ready() -> void:
	pressed.connect(_on_pressed)


func _set_building(new_building: BuildingData.Building) -> void:
	building = new_building
	text = BuildingData.get_building_name(building)


func _on_pressed() -> void:
	building_selected.emit(building)
