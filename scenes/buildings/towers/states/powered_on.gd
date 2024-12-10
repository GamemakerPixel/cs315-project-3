extends TowerState


func on_entry() -> void:
	_tower.consuming_energy = true


func on_physics_process(delta: float) -> void:
	_tower.consume_energy(delta)
	_tower.look_at_from_position(_tower.global_position, _tower.target.global_position)
	_tower.rotation.x = 0
	_tower.rotation.z = 0


func on_charged() -> void:
	_tower.attack()


func target_changed() -> void:
	if _tower.target == null:
		_state_machine.change_state_to(TowerStateMachine.State.WAITING)


func on_exit() -> void:
	pass
