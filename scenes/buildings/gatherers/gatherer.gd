class_name Gatherer
extends Chargable

@export var consumable := ConsumablePool.Consumable.COAL
@export var detection_area: Area3D

@onready var _state_machine: GathererStateMachine = $States

# Set by Buildings
var consumable_pool: ConsumablePool

var deposits_in_range: Array[ResourceDeposit] = []
var active_deposit: ResourceDeposit = null : set = _set_active_deposit


func _ready() -> void:
	_state_machine.initialize(self)
	detection_area.area_entered.connect(_on_deposit_entered)
	detection_area.area_exited.connect(_on_deposit_exited)


func gather_resource() -> void:
	var amount = active_deposit.gather_resource()
	consumable_pool.supply(consumable, amount)


func _on_charged() -> void:
	_state_machine.on_charged()


func _on_deposit_entered(area: Area3D) -> void:
	var deposit := area as ResourceDeposit
	
	if not deposit.consumable == consumable:
		return
	
	deposits_in_range.append(deposit)
	_refresh_active_deposit()


func _on_deposit_exited(area: Area3D) -> void:
	var deposit := area as ResourceDeposit
	
	if not deposit.consumable == consumable:
		return
	
	deposits_in_range.remove_at(
		deposits_in_range.find(deposit)
	)
	_refresh_active_deposit()


func _refresh_active_deposit() -> void:
	if deposits_in_range.is_empty():
		active_deposit = null
	else:
		active_deposit = deposits_in_range[0]


func _set_active_deposit(new_deposit: ResourceDeposit) -> void:
	active_deposit = new_deposit
	_state_machine.on_active_deposit_changed()
