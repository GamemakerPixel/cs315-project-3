extends Node


@onready var vehicle: Node3D = $SubViewport/Vehicle


func _init() -> void:
	set_process_input(false)


func _ready() -> void:
	$UI.building_selected.connect($SubViewport/Vehicle.building_selected)
