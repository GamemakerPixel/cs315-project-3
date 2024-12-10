extends GathererState


func on_entry() -> void:
	_gatherer.consuming_energy = true


func on_physics_process(delta: float) -> void:
	_gatherer.consume_energy(delta)


func on_charged() -> void:
	_gatherer.gather_resource()


func on_active_deposit_changed() -> void:
	if _gatherer.active_deposit == null:
		_state_machine.change_state_to(GathererStateMachine.State.WAITING)


func on_exit() -> void:
	pass
