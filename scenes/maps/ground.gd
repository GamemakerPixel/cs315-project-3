extends GridMap

const DIMENSIONS = Vector2i(50, 50)


func _ready() -> void:
	_generate_map()


func _generate_map() -> void:
	for x in range(-DIMENSIONS.x, DIMENSIONS.x + 1):
		for z in range(-DIMENSIONS.y, DIMENSIONS.y + 1):
			set_cell_item(Vector3i(x, 0, z), 0)
