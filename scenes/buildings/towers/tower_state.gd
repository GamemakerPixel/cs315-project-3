class_name TowerState
extends Node

var _state_machine: TowerStateMachine
var _tower: Tower


func initialize(state_machine: TowerStateMachine, tower: Tower) -> void:
	self._state_machine = state_machine
	self._tower = tower


func on_entry() -> void:
	pass


func on_physics_process(_delta: float) -> void:
	pass


func on_charged() -> void:
	pass


func target_changed() -> void:
	pass


func on_exit() -> void:
	pass
