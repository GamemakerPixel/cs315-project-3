extends Node3D

const PLATFORM_TILE = 0

var placement_enabled := false : set = _set_placement_enabled

var _currently_placing := false
var _platform_placing_enabled := false

var _current_building_scene: PackedScene


func _ready() -> void:
	# Triggering the setter.
	placement_enabled = placement_enabled
	$PlacementPreview.placing_platforms = _platform_placing_enabled


func _unhandled_input(event: InputEvent) -> void:
	if not placement_enabled:
		return
	if event.is_action("place"):
		_currently_placing = Input.is_action_pressed("place")
	if event.is_action_pressed("cancel"):
		placement_enabled = false


func _process(_delta: float) -> void:
	if _currently_placing:
		_place_at_mouse_position()


func select_building(building: BuildingData.Building) -> void:
	$PlacementPreview.mesh = BuildingData.get_building_mesh(building)
	_current_building_scene = BuildingData.get_building_scene(building)
	placement_enabled = true


func _place_at_mouse_position() -> void:
	var tile_coords = $PlacementPreview.get_current_tile_coordinates()
	
	if _platform_placing_enabled:
		$GridMap.set_cell_item(tile_coords, PLATFORM_TILE)
		return
	
	var platform_tile_coords = tile_coords + Vector3i.DOWN
	# Prevents placing towers off the vehicle.
	if $GridMap.get_cell_item(platform_tile_coords) != PLATFORM_TILE:
		return
	
	var building = _current_building_scene.instantiate()
	building.position = $PlacementPreview.get_local_coordinates()
	$Buildings.add_child(building)


func _set_placement_enabled(new_placement_enabled: bool) -> void:
	placement_enabled = new_placement_enabled
	_currently_placing = false
	$PlacementPreview.enabled = placement_enabled
