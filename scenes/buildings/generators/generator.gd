class_name Generator
extends Node3D

signal adjust_power(power: float)

@export var power_provided := 5 #kW
@export var consumable_used: ConsumablePool.Consumable = (
	ConsumablePool.Consumable.DAYLIGHT
)
@export var minimum_amount := 0.1
@export var maximum_amount := 1.0
@export var minimum_duration := 1.0
@export var maximum_duration := 1.0

# Set by Buildings
var consumable_pool: ConsumablePool

@onready var _state_machine: GeneratorStateMachine = $States
@onready var _use_timer = Timer.new()

var producing: bool = false : set = _set_producing


func _ready() -> void:
	_use_timer.one_shot = true
	_use_timer.timeout.connect(_on_resources_needed)
	add_child(_use_timer)
	_state_machine.initialize(self)


func use_amount(amount: float) -> void:
	# Time able to produce for is directly related to how much of a resource
	# is used.
	var production_time: float 
	if minimum_duration == maximum_duration:
		production_time = maximum_duration
	else:
		production_time = lerp(
			minimum_duration,
			maximum_duration,
			inverse_lerp(
				minimum_amount,
				maximum_amount,
				amount
			)
		)
	
	_use_for_time(production_time)


func _use_for_time(time: float) -> void:
	_use_timer.wait_time = time
	_use_timer.start()


func _on_resources_needed() -> void:
	_state_machine.on_resources_needed()


func _set_producing(new_producing: bool) -> void:
	if producing == new_producing:
		return
	producing = new_producing
	adjust_power.emit(power_provided * (1 if producing else -1))
	if producing:
		$PowerOn.play()
	else:
		$PowerOff.play()
