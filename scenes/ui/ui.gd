extends CanvasLayer

signal building_selected(building: BuildingData.Building)

const _BUILDING_BUTTON_SCENE = preload("res://scenes/ui/building_button.tscn")
const _RESOURCE_ENTRY_SCENE = preload("res://scenes/ui/resource_entry.tscn")
const _HEALTH_ANIM_SPEED = 0.1
const _TRACKED_RESOURCES = [
	ConsumablePool.Consumable.LUMBER,
	ConsumablePool.Consumable.COAL,
	ConsumablePool.Consumable.IRON,
	ConsumablePool.Consumable.GOLD,
]

@export var health_progress: ProgressBar

@onready var _category_nodes: Dictionary = {
	"resources": $Margin/HBox/Build/Buildings/Resources/Scroll/Entries,
	"tower": $Margin/HBox/Build/Buildings/Towers/Scroll/Options,
	"generator": $Margin/HBox/Build/Buildings/Generators/Scroll/Options,
	"gatherer": $Margin/HBox/Build/Buildings/Gatherers/Scroll/Options,
}

# Set by Map
var consumable_pool: ConsumablePool : set = _on_consumable_pool_set

var _building_ui_visible := false : set = _set_building_ui_visible
# Consumable: func(amount) that updates UI
var _count_updaters: Dictionary


func _ready() -> void:
	_set_initial_state()
	_clear_placeholders()
	_add_building_buttons()


func show_game_over() -> void:
	$Margin.hide()
	$GameOver.show()


func show_win() -> void:
	$Margin.hide()
	$Win.show()


func _set_initial_state() -> void:
	$Margin/HBox/Build/Buildings/Resources.show()
	$Margin/HBox/Build/Buildings.hide()
	$Margin.show()
	$GameOver.hide()
	$Win.hide()


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


func _add_resource_entries() -> void:
	for consumable in _TRACKED_RESOURCES:
		var initial_count := consumable_pool.query_amount(consumable)
		var entry = _RESOURCE_ENTRY_SCENE.instantiate()
		entry.set_initial_values(consumable, initial_count)
		_count_updaters[consumable] = entry.set_count
		_category_nodes["resources"].add_child(entry)


func _set_building_ui_visible(new_building_ui_visible: bool) -> void:
	_building_ui_visible = new_building_ui_visible
	$Margin/HBox/Build/Buildings.visible = new_building_ui_visible


func _on_visibility_button_pressed() -> void:
	_building_ui_visible = not _building_ui_visible

# Forwarding the building_selected signal from all of the buttons so nodes that
# need it only need to connect to the signal from the UI node.
func _on_building_selected(building: BuildingData.Building) -> void:
	building_selected.emit(building)
	_building_ui_visible = false


func _on_resource_count_updated(
	consumable: ConsumablePool.Consumable,
	amount: float
) -> void:
	if consumable in _count_updaters:
		_count_updaters[consumable].call(amount)


func _on_consumable_pool_set(pool: ConsumablePool) -> void:
	consumable_pool = pool
	_add_resource_entries()
	consumable_pool.subscribe_to_all_changes(_on_resource_count_updated)


func set_max_health(health: int) -> void:
	health_progress.max_value = health
	health_progress.value = health


func set_health(health: int) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(health_progress, "value", health, _HEALTH_ANIM_SPEED)


func set_power(power: float) -> void:
	$Margin/HBox/Stats/VBox/EnergyIndicator.power = power
