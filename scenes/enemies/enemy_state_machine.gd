class_name EnemyStateMachine
extends Node

enum State {
	ON_GROUND,
	MOUNTING_VEHICLE,
	ON_VEHICLE,
	EXPLODING,
}

const INITIAL_STATE = State.ON_GROUND

@onready var _state_nodes: Dictionary = {
	State.ON_GROUND: $OnGround,
	State.MOUNTING_VEHICLE: $MountingVehicle,
	State.ON_VEHICLE: $OnVehicle,
	State.EXPLODING: $Exploding,
}

var _enemy: Enemy
var _current_state: EnemyState = null


func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED


func initialize(enemy: Enemy) -> void:
	self._enemy = enemy
	change_state_to(INITIAL_STATE)
	process_mode = ProcessMode.PROCESS_MODE_INHERIT


func change_state_to(state: State) -> void:
	if _current_state:
		_current_state.on_exit()
	_current_state = _state_nodes[state]
	_current_state.initialize(self, _enemy)
	_current_state.on_entry()


func _physics_process(delta: float) -> void:
	_current_state.on_physics_process(delta)
