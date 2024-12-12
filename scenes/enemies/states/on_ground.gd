extends EnemyState


func on_entry() -> void:
	_enemy.body_entered.connect(_on_collision_with_vehicle)


func on_physics_process(delta: float) -> void:
	var target: Vector3 = _enemy.get_target_position()
	var direction = (target - _enemy.global_position).normalized()
	_enemy.position += direction * _enemy.speed * delta


func on_exit() -> void:
	_enemy.body_entered.disconnect(_on_collision_with_vehicle)


func _on_collision_with_vehicle(_body: Node3D) -> void:
	_state_machine.change_state_to(EnemyStateMachine.State.MOUNTING_VEHICLE)
