class_name TowerStateMachine
extends Node


enum State {
	POWERED_ON,
	WAITING,
	POWERED_OFF,
}

const INITIAL_STATE = State.WAITING

@onready var _state_nodes: Dictionary = {
	State.POWERED_ON: $PoweredOn,
	State.WAITING: $Waiting,
	State.POWERED_OFF: $PoweredOff,
}

var _tower: Tower
var _current_state: TowerState = null


func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED


func initialize(tower: Tower) -> void:
	self._tower = tower
	change_state_to(INITIAL_STATE)
	process_mode = ProcessMode.PROCESS_MODE_INHERIT


func change_state_to(state: State) -> void:
	if _current_state:
		_current_state.on_exit()
	_current_state = _state_nodes[state]
	_current_state.initialize(self, _tower)
	_current_state.on_entry()


func on_charged() -> void:
	if _current_state:
		_current_state.on_charged()


func target_changed() -> void:
	if _current_state:
		_current_state.target_changed()


func _physics_process(delta: float) -> void:
	_current_state.on_physics_process(delta)
