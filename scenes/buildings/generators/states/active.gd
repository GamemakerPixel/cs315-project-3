extends GeneratorState


func on_entry() -> void:
	_generator.producing = true


func on_resources_needed() -> void:
	var amount_used = _generator.consumable_pool.use(
		_generator.consumable_used,
		_generator.maximum_amount,
		_generator.minimum_amount
	)
	
	if amount_used == 0.0:
		_state_machine.change_state_to(GeneratorStateMachine.State.INACTIVE)
		return
	
	_generator.use_amount(amount_used)


func on_exit() -> void:
	pass
