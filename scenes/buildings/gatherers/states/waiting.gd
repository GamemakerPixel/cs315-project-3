extends GathererState


func on_entry() -> void:
	pass


func on_physics_process(delta: float) -> void:
	_gatherer.consume_energy(delta)


func on_charged() -> void:
	_state_machine.change_state_to(GathererStateMachine.State.INACTIVE)


func on_active_deposit_changed() -> void:
	if not _gatherer.active_deposit == null:
		_state_machine.change_state_to(GathererStateMachine.State.ACTIVE)


func on_exit() -> void:
	pass
