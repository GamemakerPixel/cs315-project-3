class_name EnemyState
extends Node


var _state_machine: EnemyStateMachine
var _enemy: Enemy


func initialize(state_machine: EnemyStateMachine, enemy: Enemy) -> void:
	self._state_machine = state_machine
	self._enemy = enemy


func on_entry() -> void:
	pass


func on_physics_process(_delta: float) -> void:
	pass


func on_exit() -> void:
	pass
