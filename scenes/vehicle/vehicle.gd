extends AnimatableBody3D

const MAX_LINEAR_SPEED = 1.5 # m/sec
const LINEAR_ACCELERATION = 1.5 # m/sec^2
const LINEAR_DECELERATION = 6 # m/sec^2

const MAX_ROTATION_SPEED = 0.05 # rot/sec
const ROTATION_ACCELERATION = 0.2 # rot/sec^2
const ROTATION_DECELERATION = 0.3 # rot/sec^2

var _drive_input := 0
var _turn_input := 0

var _current_linear_velocity = 0.0
var _current_rotational_velocity = 0.0

var _currently_placing := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("forward") or event.is_action("backward"):
		_drive_input = int(Input.get_axis("backward", "forward"))
	if event.is_action("turn_left") or event.is_action("turn_right"):
		_turn_input = int(Input.get_axis("turn_right", "turn_left"))
	if event.is_action("place"):
		_currently_placing = Input.is_action_pressed("place")


func _process(_delta: float) -> void:
	if _currently_placing:
		_place_at_mouse_position()


func _physics_process(delta: float) -> void:
	_turn(delta)
	_drive(delta)


func _drive(delta: float) -> void:
	var forward_direction = -transform.basis.z
	var velocity = _calculate_linear_velocity(delta)
	position += forward_direction * velocity * delta
	_current_linear_velocity = velocity


func _calculate_linear_velocity(delta: float) -> float:
	return _calculate_velocity(
		delta, MAX_LINEAR_SPEED, _drive_input, _current_linear_velocity,
		LINEAR_ACCELERATION, LINEAR_DECELERATION
	)


func _turn(delta: float) -> void:
	var velocity = _calculate_rotational_velocity(delta)
	rotation.y += velocity * TAU * delta
	_current_rotational_velocity = velocity


func _calculate_rotational_velocity(delta: float) -> float:
	return _calculate_velocity(
		delta, MAX_ROTATION_SPEED, _turn_input, _current_rotational_velocity,
		ROTATION_ACCELERATION, ROTATION_DECELERATION
	)


func _calculate_velocity(
	delta: float, max_speed: float, input: float, current: float,
	acceleration: float, deceleration: float
) -> float:
	var target_velocity = input * max_speed
	var target_direction = sign(target_velocity - current)
	# Check if we are decelerating
	var chosen_acceleration = acceleration if (
		signf(current) == target_direction
	) else deceleration
	
	var velocity = current + target_direction * chosen_acceleration * delta
	var resulting_target_direction = sign(target_velocity - velocity)
	if resulting_target_direction != target_direction:
		velocity = target_velocity
	return velocity


func _place_at_mouse_position() -> void:
	var tile_coords = $PlacementPreview.get_current_tile_coordinates()
	$GridMap.set_cell_item(tile_coords, 0)
