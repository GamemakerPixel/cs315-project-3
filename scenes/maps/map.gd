extends SubViewportContainer

@export var vehicle: Node3D

const MAX_HEALTH = 100
const REGENERATION_TIME = 15.0 # Seconds to regenerate one unit of health.
const BASE_POWER = 10 #kW
const GOLD_REQUIREMENT = 3 # How much gold is needed to win the game.

var consumable_pool = ConsumablePool.new()

var vehicle_health := MAX_HEALTH : set = _set_vehicle_health
var power_avaliable := BASE_POWER : set = _set_power_avaliable


func _init() -> void:
	set_process_input(false)
	if (DebugTools.check_enabled(DebugTools.DebugTool.WIDE_CAMERA)):
		stretch_shrink = 1


func _ready() -> void:
	$UI.building_selected.connect(vehicle.building_selected)
	_initialize_global_values()
	_create_health_regeneration_timer()
	consumable_pool.subscribe_to_all_changes(_on_consumable_updated)


func _initialize_global_values() -> void:
	vehicle_health = vehicle_health
	power_avaliable = power_avaliable
	vehicle.consumable_pool = consumable_pool
	$UI.consumable_pool = consumable_pool


func _create_health_regeneration_timer() -> void:
	# Don't regenerate health in this case.
	if REGENERATION_TIME <= 0:
		return
	
	var timer = Timer.new()
	timer.wait_time = REGENERATION_TIME
	timer.timeout.connect(func():
		vehicle_health += 1
	)
	timer.one_shot = false
	add_child(timer)
	timer.start()


func _game_over() -> void:
	$UI.show_game_over()
	$SubViewport/World.process_mode = Node.PROCESS_MODE_DISABLED


func _set_vehicle_health(new_health: int) -> void:
	vehicle_health = clampi(new_health, 0, MAX_HEALTH)
	$UI.set_health(vehicle_health)
	if vehicle_health == 0:
		_game_over()


func _set_power_avaliable(new_power: int) -> void:
	power_avaliable = new_power
	vehicle.set_power_avaliable(power_avaliable)
	$UI.set_power(power_avaliable)


func _on_watchtower_attacked(damage: int) -> void:
	$HurtSound.play()
	if DebugTools.check_enabled(DebugTools.DebugTool.INVINCIBLE):
		return
	vehicle_health -= damage


# For adding/removing generators and for when the vehicle moves.
func _change_power(amount: int) -> void:
	power_avaliable += amount


func _on_consumable_updated(consumable: ConsumablePool.Consumable, amount: float) -> void:
	if consumable == ConsumablePool.Consumable.GOLD and amount == 3.0:
		$UI.show_win()
		$SubViewport/World.process_mode = Node.PROCESS_MODE_DISABLED
