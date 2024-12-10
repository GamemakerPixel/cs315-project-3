extends Node3D

signal send_power_change(amount: float)

# Set by PlacementSystem
var consumable_pool: ConsumablePool

var power_avaliable := 0 : set = _set_power_availiable

var _blocked_positions: Array[Vector3] = []
# Vector3 : Building (Node3D)
var _buildings_by_position: Dictionary = {}
var _power_consumers: Array[Chargable] = []


func _ready() -> void:
	for child in get_children():
		_blocked_positions.append(child.position)


func track_building(building: Node3D) -> void:
	if building is Chargable:
		building.start_energy_consumption.connect(func():
			_add_power_consumer(building)
		)
		building.stop_energy_consumption.connect(func():
			_remove_power_consumer(building)
		)
	if building is Generator:
		building.consumable_pool = consumable_pool
		building.adjust_power.connect(_on_generator_adjusted_power)
	if building is Gatherer:
		building.consumable_pool = consumable_pool
	_buildings_by_position[building.position] = building


func untrack_building(building_position: Vector3) -> void:
	if not _buildings_by_position.has(building_position):
		return
	var building = _buildings_by_position[building_position]
	_buildings_by_position.erase(building_position)
	if building is Chargable:
		var consumer_index = _power_consumers.find(building)
		if consumer_index != -1:
			_power_consumers.remove_at(consumer_index)
	if building is Generator:
		if building.producing:
			_on_generator_adjusted_power(building.power_provided)


func is_position_occupied(pos: Vector3) -> bool:
	for blocked_pos in _blocked_positions:
		if blocked_pos.distance_to(pos) < 0.002:
			return true
	
	return _buildings_by_position.has(pos)


func _add_power_consumer(building: Chargable) -> void:
	_power_consumers.append(building)
	_refresh_power_avaliable()


func _remove_power_consumer(building: Chargable) -> void:
	var consumer_index = _power_consumers.find(building)
	_power_consumers.remove_at(consumer_index)
	_refresh_power_avaliable()


func _refresh_power_avaliable() -> void:
	# This could also be triggered by the player starting to move, so we
	# need to handle the case where there aren't any power consumers to avoid
	# division by zero.
	if _power_consumers.is_empty():
		return
	
	var power_per_consumer = float(power_avaliable) / _power_consumers.size()
	for consumer in _power_consumers:
		consumer.power_per_consumer = power_per_consumer


func _on_generator_adjusted_power(power_change: float) -> void:
	send_power_change.emit(power_change)


func _set_power_availiable(new_power_availiable: int) -> void:
	power_avaliable = new_power_availiable
	_refresh_power_avaliable()
