extends Control

@export var camera: Camera3D

@onready var canvas_size: Vector2 = size
@onready var aspect_ratio: float = canvas_size.x / canvas_size.y
@onready var camera_angle: float = -camera.rotation.x
@onready var multipliers: Vector2 = Vector2(
	camera.size,
	camera.size / aspect_ratio / sin(camera_angle)
)

func _init() -> void:
	set_process_input(false)


func get_3d_mouse_position(y: float) -> Vector3:
	var canvas_position = get_global_mouse_position()
	var center_point = canvas_size / 2.0
	var canvas_position_local_to_center = canvas_position - center_point
	var canvas_position_relative_to_size = (
		canvas_position_local_to_center / canvas_size
	)
	
	var offset_from_angle_to_offset_xz_plane = y * tan(camera_angle)
	return Vector3(
		canvas_position_relative_to_size.x * multipliers.x,
		y,
		canvas_position_relative_to_size.y * multipliers.y + offset_from_angle_to_offset_xz_plane
	)
