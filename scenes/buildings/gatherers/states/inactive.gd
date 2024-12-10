extends GathererState


func on_entry() -> void:
	_gatherer.consuming_energy = false


func on_active_deposit_changed() -> void:
	if not _gatherer.active_deposit == null:
		_gatherer.gather_resource()
		_state_machine.change_state_to(GathererStateMachine.State.ACTIVE)


func on_exit() -> void:
	pass
