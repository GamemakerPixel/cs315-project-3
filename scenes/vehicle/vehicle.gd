extends Node3D

signal change_power(amount: int)

const MAX_LINEAR_SPEED = 3.0 # m/sec
const LINEAR_ACCELERATION = 3.0 # m/sec^2
const LINEAR_DECELERATION = 12 # m/sec^2

const MAX_ROTATION_SPEED = 0.05 # rot/sec
const ROTATION_ACCELERATION = 0.2 # rot/sec^2
const ROTATION_DECELERATION = 0.3 # rot/sec^2

const MOVEMENT_POWER_COST = 5.0 # kW

# Set by Map
var consumable_pool: ConsumablePool:
	set(new_consumable_pool):
		consumable_pool = new_consumable_pool
		$PlacementSystem.consumable_pool = consumable_pool

var _drive_input := 0 : set = _set_drive_input
var _turn_input := 0

var _current_linear_velocity = 0.0
var _current_rotational_velocity = 0.0


func _ready() -> void:
	# WORKAROUND FOR POSSIBLE ENGINE BUG
	# Godot will not save or rebake the navigation mesh if I change scenes while
	# this is enabled in the editor, thus I'm forcing it to bake the mesh when it
	# loads the vehicle into the scene.
	$PlacementSystem/GridMap.bake_navigation = true
	_load_wide_camera()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("forward") or event.is_action("backward"):
		_drive_input = int(Input.get_axis("backward", "forward"))
		consumable_pool.supply(
			ConsumablePool.Consumable.WIND,
			1.0 if _drive_input != 0.0 else 0.0
		)
	if event.is_action("turn_left") or event.is_action("turn_right"):
		_turn_input = int(Input.get_axis("turn_right", "turn_left"))


func _physics_process(delta: float) -> void:
	_turn(delta)
	_drive(delta)


func building_selected(building: BuildingData.Building) -> void:
	$PlacementSystem.select_building(building)


# Can be signaled by Buildings for adding and removing generators and can be
# called locally for movement.
func send_power_change(amount: float) -> void:
	change_power.emit(amount)


# While this is just a proxy function for now, adding different movement speed
# options (with different power consumption) would require this function too.
func set_power_avaliable(power: int) -> void:
	$PlacementSystem/Buildings.power_avaliable = power


func _load_wide_camera() -> void:
	if DebugTools.check_enabled(DebugTools.DebugTool.WIDE_CAMERA):
		$Camera3D.size *= 10
		$Camera3D.position *= 10


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


func _set_drive_input(new_drive_input: int) -> void:
	if new_drive_input != _drive_input:
		if new_drive_input != 0:
			send_power_change(-MOVEMENT_POWER_COST)
		else:
			send_power_change(MOVEMENT_POWER_COST)
		_drive_input = new_drive_input
