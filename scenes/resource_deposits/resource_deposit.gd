class_name ResourceDeposit
extends Area3D

@export var consumable := ConsumablePool.Consumable.COAL
@export var amount := 50.0
@export var amount_per_gatherer_cycle := 1.0


func gather_resource() -> float:
	if amount_per_gatherer_cycle >= amount:
		$Animation.play("disappear")
		if has_node("Obtain"):
			$Obtain.play()
		return amount
	
	amount -= amount_per_gatherer_cycle
	return amount_per_gatherer_cycle


func _on_animation_finished(_anim_name: StringName) -> void:
	queue_free()
