extends EnemyState


func on_entry() -> void:
	_enemy.force_untarget()
	_enemy.attacked_watchtower.emit(_enemy.damage)
	_enemy.queue_free()


func on_physics_process(_delta: float) -> void:
	pass


func on_exit() -> void:
	pass
