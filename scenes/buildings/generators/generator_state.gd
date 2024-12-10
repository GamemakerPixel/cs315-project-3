class_name GeneratorState
extends Node

var _state_machine: GeneratorStateMachine
var _generator: Generator


func initialize(state_machine: GeneratorStateMachine, generator: Generator) -> void:
	self._state_machine = state_machine
	self._generator = generator


func on_entry() -> void:
	pass


func on_resources_needed() -> void:
	pass


func on_exit() -> void:
	pass
