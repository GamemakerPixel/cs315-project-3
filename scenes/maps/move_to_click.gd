extends MeshInstance3D

const PLATFORM_Y = 0.0
const BUILDING_Y = 1.0

@export var mouse_detector: Control
@export var gridmap: GridMap

var enabled := false : set = _set_enabled
var placing_platforms := false : set = _set_placing_platforms

var _y_level := 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		enabled = false


func _process(_delta: float) -> void:
	if not enabled:
		return
	var mouse_target = mouse_detector.get_3d_mouse_position(_y_level).rotated(Vector3.UP, rotation.y)
	position = _round_local(mouse_target).rotated(Vector3.UP, -rotation.y) + gridmap.position


func get_current_tile_coordinates() -> Vector3i:
	var local_to_gridmap = position.rotated(Vector3.UP, -rotation.y)
	return gridmap.local_to_map(local_to_gridmap)


func get_local_coordinates() -> Vector3:
	return gridmap.map_to_local(get_current_tile_coordinates()).rotated(
		Vector3.UP, rotation.y
	) + gridmap.position


func load_building(building: BuildingData.Building) -> void:
	mesh = BuildingData.get_building_mesh(building)
	if not BuildingData.get_building_category(building) == "tower":
		$RangeIndicator.hide()
		return
	
	var tower_stats: BuildingData.TowerStats = BuildingData.get_tower_stats(building)
	$RangeIndicator.scale = Vector3(
		tower_stats.attack_range,
		1.0,
		tower_stats.attack_range
	)
	$RangeIndicator.show()



func _round_local(true_position: Vector3) -> Vector3:
	return gridmap.map_to_local(gridmap.local_to_map(true_position))


func _set_enabled(new_enabled: bool) -> void:
	enabled = new_enabled
	visible = new_enabled


func _set_placing_platforms(new_placing_platforms: bool) -> void:
	placing_platforms = new_placing_platforms
	_y_level = PLATFORM_Y if placing_platforms else BUILDING_Y
