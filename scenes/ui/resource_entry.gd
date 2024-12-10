extends Label

const DELIMITER = ": "
const CONSUMABLE_DISPLAY_NAME = {
	ConsumablePool.Consumable.LUMBER: "Lumber",
	ConsumablePool.Consumable.COAL: "Coal",
	ConsumablePool.Consumable.IRON: "Iron",
	ConsumablePool.Consumable.GOLD: "Gold",
}

var consumable: ConsumablePool.Consumable
var count: float = 0.0 : set = set_count

# Godot has constructors, but only when calling .new, not .instantiate.
@warning_ignore("shadowed_variable")
func set_initial_values(
	consumable: ConsumablePool.Consumable,
	initial_count: float
) -> void:
	self.consumable = consumable
	self.count = initial_count


func set_count(new_count: float) -> void:
	count = new_count
	text = CONSUMABLE_DISPLAY_NAME[consumable] + DELIMITER + str(count)
