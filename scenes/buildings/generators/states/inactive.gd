extends GeneratorState


func on_entry() -> void:
	_generator.producing = false
	_generator.consumable_pool.use_when_avaliable(
		_on_resource_given,
		_generator.consumable_used,
		_generator.maximum_amount,
		_generator.minimum_amount,
	)


func on_exit() -> void:
	pass


func _on_resource_given(amount: float) -> void:
	_generator.use_amount(amount)
	_state_machine.change_state_to(GeneratorStateMachine.State.ACTIVE)
