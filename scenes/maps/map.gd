extends Node


func _init() -> void:
	set_process_input(false)


func _ready() -> void:
	$UI.building_selected.connect($SubViewport/Vehicle.building_selected)
