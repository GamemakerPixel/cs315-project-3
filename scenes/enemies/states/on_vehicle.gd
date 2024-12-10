extends EnemyState


func on_entry() -> void:
	_enemy.navigation.target_reached.connect(_on_target_reached)


func on_physics_process(delta: float) -> void:
	var target_position = _enemy.get_target_position()
	_enemy.navigation.target_position = target_position
	
	var navigation_point := _enemy.navigation.get_next_path_position()
	var direction = (navigation_point - _enemy.global_position).normalized()
	_enemy.global_position += direction * _enemy.speed * delta


func on_exit() -> void:
	_enemy.navigation.target_reached.disconnect(_on_target_reached)


func _on_target_reached() -> void:
	_state_machine.change_state_to(EnemyStateMachine.State.ATTACKING)
