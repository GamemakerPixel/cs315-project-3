class_name GathererState
extends Node

var _state_machine: GathererStateMachine
var _gatherer: Gatherer


func initialize(state_machine: GathererStateMachine, gatherer: Gatherer) -> void:
	self._state_machine = state_machine
	self._gatherer = gatherer


func on_entry() -> void:
	pass


func on_physics_process(_delta: float) -> void:
	pass


func on_charged() -> void:
	pass


func on_active_deposit_changed() -> void:
	pass


func on_exit() -> void:
	pass
