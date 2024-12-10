extends Control

const POWER_UNIT = " kW"

var power: float = 0 : set = _set_power


func _set_power(new_power: float) -> void:
	power = new_power
	$Value.text = str(power) + POWER_UNIT
