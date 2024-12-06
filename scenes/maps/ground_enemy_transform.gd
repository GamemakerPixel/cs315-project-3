extends EnemyTransform

@export var vehicle: Node3D


func get_target_position() -> Vector3:
	return vehicle.global_position
