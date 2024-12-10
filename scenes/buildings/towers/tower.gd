extends Chargable
class_name Tower

@export var damage: int = 5
@export var face_target: bool = false

@onready var _state_machine: TowerStateMachine = $States

# Queue of enemies in order of when they entered the tower's range,
# first in this queue will become the target.
var _enemies_in_range: Array[Enemy] = []
var target: Enemy = null


func _ready() -> void:
	_state_machine.initialize(self)

# Would probably be better to use a timer for this later, but would require
# more advanced updates when the amount of power avaliable changes mid-charge.
func consume_energy(delta: float) -> void:
	current_charge += delta * power_per_consumer


func attack() -> void:
	target.take_damage(damage)
	$Attack.play()


func _on_charged() -> void:
	_state_machine.on_charged()


func _refresh_target() -> void:
	var previous_target = target
	if _enemies_in_range.size() >= 1:
		target = _enemies_in_range[0]
	else:
		target = null
	if not previous_target == target:
		_state_machine.target_changed()


func _enemy_entered_range(enemy: Area3D) -> void:
	_enemies_in_range.append(enemy as Enemy)
	if target == null:
		_refresh_target()


func _enemy_exited_range(enemy: Area3D) -> void:
	_enemies_in_range.remove_at(_enemies_in_range.find(enemy))
	if enemy == target:
		_refresh_target()
