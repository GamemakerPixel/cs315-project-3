class_name EnemyTransform
extends Node3D


# Always returns global coordinates
func get_target_position() -> Vector3:
	return global_position
