extends EnemyState


func on_entry() -> void:
	pass


func on_physics_process(_delta: float) -> void:
	_enemy.navigation.target_position = _enemy.get_target_position.call()
	print(_enemy.navigation.get_next_path_position() - _enemy.global_position)


func on_exit() -> void:
	pass
