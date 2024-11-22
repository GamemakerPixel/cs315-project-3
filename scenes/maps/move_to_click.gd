extends Node3D

@export var mouse_detector: Control
@export var gridmap: GridMap

var enabled := true : set = _set_enabled
var y_level := 0


func _process(_delta: float) -> void:
	if not enabled:
		return
	var mouse_target = mouse_detector.get_3d_mouse_position(y_level).rotated(Vector3.UP, rotation.y)
	position = _round_local(mouse_target).rotated(Vector3.UP, -rotation.y) + gridmap.position

func get_current_tile_coordinates() -> Vector3i:
	var local_to_gridmap = position.rotated(Vector3.UP, -rotation.y)
	return gridmap.local_to_map(local_to_gridmap)

func _round_local(true_position: Vector3) -> Vector3:
	return gridmap.map_to_local(gridmap.local_to_map(true_position))

func _set_enabled(new_enabled: bool) -> void:
	enabled = new_enabled
	visible = new_enabled
