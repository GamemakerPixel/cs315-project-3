class_name GeneratorStateMachine
extends Node


enum State {
	ACTIVE,
	INACTIVE,
}

const INITIAL_STATE = State.INACTIVE

@onready var _state_nodes: Dictionary = {
	State.ACTIVE: $Active,
	State.INACTIVE: $Inactive,
}

var _generator: Generator
var _current_state: GeneratorState = null


func initialize(generator: Generator) -> void:
	self._generator = generator
	change_state_to(INITIAL_STATE)


func change_state_to(state: State) -> void:
	if _current_state:
		_current_state.on_exit()
	_current_state = _state_nodes[state]
	_current_state.initialize(self, _generator)
	_current_state.on_entry()


func on_resources_needed() -> void:
	_current_state.on_resources_needed()
