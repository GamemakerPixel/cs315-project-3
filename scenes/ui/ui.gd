extends CanvasLayer

signal building_selected(building: BuildingData.Building)

const _BUILDING_BUTTON_SCENE = preload("res://scenes/ui/building_button.tscn")

@onready var _category_nodes: Dictionary = {
	"action": $Margin/HBox/Buildings/Actions/Scroll/Options,
	"tower": $Margin/HBox/Buildings/Towers/Scroll/Options,
	"generator": $Margin/HBox/Buildings/Generators/Scroll/Options,
	"gatherer": $Margin/HBox/Buildings/Gatherers/Scroll/Options,
}

var _building_ui_visible := false : set = _set_building_ui_visible

func _ready() -> void:
	_set_initial_state()
	_clear_placeholders()
	_add_building_buttons()


func _set_initial_state() -> void:
	$Margin/HBox/Buildings/Actions.show()
	$Margin/HBox/Buildings.hide()


func _clear_placeholders() -> void:
	for node in _category_nodes.values():
		for child in node.get_children():
			child.queue_free()


func _add_building_buttons() -> void:
	for building in BuildingData.Building.values():
		var category := BuildingData.get_building_category(building)
		var button = _BUILDING_BUTTON_SCENE.instantiate()
		button.building = building
		button.building_selected.connect(_on_building_selected)
		_category_nodes[category].add_child(button)


func _set_building_ui_visible(new_building_ui_visible: bool) -> void:
	_building_ui_visible = new_building_ui_visible
	$Margin/HBox/Buildings.visible = new_building_ui_visible


func _on_visibility_button_pressed() -> void:
	_building_ui_visible = not _building_ui_visible

# Forwarding the building_selected signal from all of the buttons so nodes that
# need it only need to connect to the signal from the UI node.
func _on_building_selected(building: BuildingData.Building) -> void:
	building_selected.emit(building)
