class_name Chargable
extends Node3D

signal start_energy_consumption
signal stop_energy_consumption

# kJ before performing an action (attacking an enemy, gathering a resource, etc.)
@export var charge_energy: float = 7.0

# Set by parent nodes, in kW (kJ / sec)
var power_per_consumer: float = 0.0 : set = _set_power_per_consumer

var consuming_energy: bool = false : set = _set_consuming_energy
var current_charge: float = 0.0 : set = _set_current_charge

# Would probably be better to use a timer for this later, but would require
# more advanced updates when the amount of power avaliable changes mid-charge.
func consume_energy(delta: float) -> void:
	current_charge += delta * power_per_consumer


func _on_charged() -> void:
	pass


func _set_consuming_energy(new_consuming_energy: bool) -> void:
	if consuming_energy != new_consuming_energy:
		consuming_energy = new_consuming_energy
		if consuming_energy:
			start_energy_consumption.emit()
		else:
			stop_energy_consumption.emit()


func _set_current_charge(new_current_charge: float) -> void:
	current_charge = new_current_charge
	if current_charge >= charge_energy:
		current_charge -= charge_energy
		_on_charged()


func _set_power_per_consumer(newpower_per_consumer: float) -> void:
	power_per_consumer = newpower_per_consumer
	# Originally this was a function for the states, but I'm choosing to leave
	# this because some towers could (in the future) base their attacks on
	# how much power is avaliable (like a continuously-attacking laser for instance).
