extends Area3D

enum State {
	TARGETING_VEHICLE,
	TARGETING_TOWER,
	ATTACKING_TOWER,
}

const SPEED = 2.25

# Order:
# immediately called on state change
# _physics_process
var _state_overrides: Dictionary = {
	State.TARGETING_VEHICLE: [
		_targeting_vehicle_start,
		_targeting_vehicle_physics_process
	]
}

var vehicle: Node3D : set = _set_vehicle

var _target: Node3D
var _current_state_overrides: Array
var _current_state: State : set = _set_current_state


func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED


func _physics_process(delta: float) -> void:
	_current_state_overrides[1].call(delta)


func _move_towards_target(delta: float) -> void:
	var direction = Vector2(
		_target.position.x - position.x,
		_target.position.z - position.z,
	).normalized()
	
	var velocity = direction * SPEED * delta
	position += Vector3(velocity.x, 0.0, velocity.y)


func _targeting_vehicle_start() -> void:
	_target = vehicle


func _targeting_vehicle_physics_process(delta: float) -> void:
	_move_towards_target(delta)


func _set_vehicle(new_vehicle: Node3D) -> void:
	vehicle = new_vehicle
	_current_state = State.TARGETING_VEHICLE


func _set_current_state(new_state: State) -> void:
	_current_state = new_state
	_current_state_overrides = _state_overrides[_current_state]
	_current_state_overrides[0].call()
	if process_mode == ProcessMode.PROCESS_MODE_DISABLED:
		process_mode = ProcessMode.PROCESS_MODE_INHERIT


func _on_body_entered(body: Node3D) -> void:
	if _current_state == State.TARGETING_VEHICLE:
		$Animation.play("jump")
		collision_mask = 4
