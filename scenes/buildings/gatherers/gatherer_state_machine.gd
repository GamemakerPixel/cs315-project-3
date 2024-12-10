class_name GathererStateMachine
extends Node

enum State {
	ACTIVE,
	WAITING,
	INACTIVE,
}

const INITIAL_STATE = State.WAITING

@onready var _state_nodes: Dictionary = {
	State.ACTIVE: $Active,
	State.WAITING: $Waiting,
	State.INACTIVE: $Inactive,
}

var _gatherer: Gatherer
var _current_state: GathererState = null


func initialize(gatherer: Gatherer) -> void:
	self._gatherer = gatherer
	change_state_to(INITIAL_STATE)


func change_state_to(state: State) -> void:
	if _current_state:
		_current_state.on_exit()
	_current_state = _state_nodes[state]
	_current_state.initialize(self, _gatherer)
	_current_state.on_entry()


func _physics_process(delta: float) -> void:
	_current_state.on_physics_process(delta)


func on_charged() -> void:
	if _current_state:
		_current_state.on_charged()


func on_active_deposit_changed() -> void:
	if _current_state:
		_current_state.on_active_deposit_changed()
