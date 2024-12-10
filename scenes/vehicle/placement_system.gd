extends Node3D

const PLATFORM_TILE = 0

@onready var building_manager = $Buildings

# Set by Vehicle
var consumable_pool: ConsumablePool:
	set(new_consumable_pool):
		consumable_pool = new_consumable_pool
		building_manager.consumable_pool = consumable_pool

var placement_enabled := false : set = _set_placement_enabled

var _currently_placing := false
var _platform_placing_enabled := false

var _current_building_scene: PackedScene
var _current_building: BuildingData.Building


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
	$PlacementPreview.load_building(building)
	_current_building_scene = BuildingData.get_building_scene(building)
	_current_building = building
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
	
	var local_coords = $PlacementPreview.get_local_coordinates()
	if building_manager.is_position_occupied(local_coords):
		return
	
	
	var building_cost = BuildingData.get_consumable_cost(_current_building)
	if not (
		DebugTools.check_enabled(DebugTools.DebugTool.FREE_BUILDINGS)
		or consumable_pool.use_many_exactly(building_cost)
	):
		# Signal UI to notify player.
		return
	
	
	var building = _current_building_scene.instantiate()
	building.position = local_coords
	building_manager.track_building(building)
	$Buildings.add_child(building)


func _set_placement_enabled(new_placement_enabled: bool) -> void:
	placement_enabled = new_placement_enabled
	_currently_placing = false
	$PlacementPreview.enabled = placement_enabled
