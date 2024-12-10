extends EnemyState


func on_entry() -> void:
	_enemy.force_untarget()
	_enemy.disable_hurt_anim = true
	_enemy.animation.animation_finished.connect(_on_anim_finished)
	_enemy.animation.play("death")
	_enemy.hurt_sound.play()


func on_physics_process(_delta: float) -> void:
	pass


func on_exit() -> void:
	pass


func _on_anim_finished(_anim_name: String) -> void:
	_enemy.queue_free()
