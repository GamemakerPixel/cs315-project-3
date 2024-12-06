class_name EnemyManager
extends Node

enum EnemyTransformName {
	GROUND,
	VEHICLE,
}

const INITIAL_TRANSFORM = EnemyTransformName.GROUND

@export var enemy_transforms: Array[EnemyTransform]


func _ready() -> void:
	var enemy_class: PackedScene = load("res://scenes/enemies/enemy.tscn")
	var enemy: Enemy = enemy_class.instantiate()
	enemy.position = Vector3(0, 0, 15)
	add_enemy(enemy)


func add_enemy(enemy: Enemy) -> void:
	var enemy_transform = enemy_transforms[INITIAL_TRANSFORM]
	enemy.get_target_position = enemy_transform.get_target_position
	enemy.request_transform.connect(func(transform: EnemyTransformName):
		_change_enemy_transform(enemy, transform)
	)
	enemy_transforms[INITIAL_TRANSFORM].add_child(enemy)


func _change_enemy_transform(enemy: Enemy, transform: EnemyTransformName) -> void:
	enemy.call_deferred("reparent", enemy_transforms[transform])
