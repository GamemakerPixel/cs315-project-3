extends EnemyState

const JUMP_ANIMATION = "jump"


func on_entry() -> void:
	_enemy.request_transform.emit(EnemyManager.EnemyTransformName.VEHICLE)
	_enemy.animation.animation_finished.connect(_on_animation_finished)
	_enemy.animation.play(JUMP_ANIMATION)


func on_exit() -> void:
	_enemy.animation.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == JUMP_ANIMATION:
		_enemy.state_machine.change_state_to(
			EnemyStateMachine.State.ON_VEHICLE
		)
