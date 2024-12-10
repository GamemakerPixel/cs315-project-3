class_name EnemyManager
extends Node

signal enemy_attacked_watchtower(damage: int)

enum EnemyTransformName {
	GROUND,
	VEHICLE,
}

const INITIAL_TRANSFORM = EnemyTransformName.GROUND

@export var enemy_transforms: Array[EnemyTransform]


func add_enemy(enemy: Enemy) -> void:
	var enemy_transform = enemy_transforms[INITIAL_TRANSFORM]
	enemy.enemy_transform = enemy_transform
	enemy.request_transform.connect(func(transform: EnemyTransformName):
		_change_enemy_transform(enemy, transform)
	)
	enemy.attacked_watchtower.connect(_on_watchtower_attacked)
	enemy_transforms[INITIAL_TRANSFORM].add_child(enemy)


func _change_enemy_transform(enemy: Enemy, transform: EnemyTransformName) -> void:
	enemy.call_deferred("reparent", enemy_transforms[transform])
	enemy.enemy_transform = enemy_transforms[transform]


func _on_watchtower_attacked(damage: int) -> void:
	enemy_attacked_watchtower.emit(damage)
