extends TowerState


func on_entry() -> void:
	pass


func on_physics_process(delta: float) -> void:
	# Busy waiting, not ideal - but works for now. In the future another state
	# could prevent this.
	if _tower.consuming_energy:
		_tower.consume_energy(delta)


func on_charged() -> void:
	_tower.consuming_energy = false


func target_changed() -> void:
	if _tower.target != null:
		_state_machine.change_state_to(TowerStateMachine.State.POWERED_ON)


func on_exit() -> void:
	pass
