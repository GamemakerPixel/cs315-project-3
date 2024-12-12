class_name Ground
extends GridMap

# Tile: % of chunk
signal chunk_distribution_updated(distribution: Dictionary)

enum Tile {
	GRASS,
	FOREST,
	MOUNTAIN,
	MAGMA,
}

class ChunkStats:
	const SIGNIFICANT_COUNT = 300

	# Tile: int
	var _tile_counts: Dictionary = {
		Tile.GRASS: 0,
		Tile.FOREST: 0,
		Tile.MOUNTAIN: 0,
		Tile.MAGMA: 0,
	}
	
	# This is done to signal that the dominant_zone has not been calculated yet.
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	var dominant_zone: Tile = -1 : get = _get_dominant_zone
	# Tile: % of chunk
	var tile_distribution: Dictionary = {} : get = _get_tile_distribution
	
	func count(tile: Tile) -> void:
		_tile_counts[tile] += 1
	
	func _get_dominant_zone() -> Tile:
		if dominant_zone != -1:
			return dominant_zone
		
		var dominant: Tile = Tile.GRASS
		for tile in _tile_counts:
			if _tile_counts[tile] >= SIGNIFICANT_COUNT:
				dominant = tile
		dominant_zone = dominant
		
		return dominant_zone
	
	# Lazy loading like this is actually somewhat beneficial here, as we only
	# need this value for the current chunk.
	func _get_tile_distribution() -> Dictionary:
		if tile_distribution:
			return tile_distribution
		
		var total_sum := 0
		for sum in _tile_counts.values():
			total_sum += sum
		
		var distribution = {}
		for tile in _tile_counts.keys():
			distribution[tile] = float(_tile_counts[tile]) / total_sum
		
		tile_distribution = distribution
		
		return tile_distribution

const TILE_TO_NOISE_MULTIPLIER = 1.0
const GROUND_LEVEL = 0
const CHUNK_SIZE = 50

@export var render_around: Node3D
@export var noise: FastNoiseLite
@export var tile_gradient_keys: Array[Tile]
@export var tile_gradient_values: Array[float]

var _current_chunk: Vector2i = Vector2i.ONE * -999 : set = _set_current_chunk
var _chunks_loaded: Array[Vector2i]: set = _set_chunks_loaded
# Chunk: ChunkStats
var _chunks_stats_loaded: Dictionary = {}


func _ready() -> void:
	noise.seed = randi()
	_current_chunk = Vector2i.ZERO


func _physics_process(_delta: float) -> void:
	var map_coords = local_to_map(render_around.position)
	_current_chunk = _tile_to_chunk(Vector2i(map_coords.x, map_coords.z))


static func chunk_to_rect(chunk: Vector2i) -> Rect2i:
	return Rect2i(
		_chunk_to_tile_origin(chunk),
		Vector2i(CHUNK_SIZE, CHUNK_SIZE)
	)


static func get_adjacent_chunks(chunk: Vector2i) -> Array[Vector2i]:
	var chunks: Array[Vector2i] = []
	
	for x_offset in range(-1, 2):
		for y_offset in range(-1, 2):
			if x_offset == 0 and y_offset == 0:
				continue
			
			chunks.append(chunk + Vector2i(x_offset, y_offset))
	
	return chunks


func tile_2d_to_local_2d(local: Vector2) -> Vector2:
	var tile_3d := tile_2d_to_local_3d(local)
	return Vector2(tile_3d.x, tile_3d.z)


func tile_2d_to_local_3d(local: Vector2) -> Vector3:
	var tile_3d := Vector3(local.x, GROUND_LEVEL, local.y)
	return map_to_local(tile_3d) - position


func local_2d_to_tile_3d(local: Vector2) -> Vector3i:
	var local_3d = Vector3(local.x, GROUND_LEVEL, local.y)
	return local_to_map(local_3d)


func local_2d_to_local_3d(local: Vector2) -> Vector3:
	return Vector3(
		local.x,
		-position.y,
		local.y
	)


static func _tile_to_chunk(tile: Vector2i) -> Vector2i:
	var negative_adjust = Vector2i(
		CHUNK_SIZE if tile.x < 0 else 0,
		CHUNK_SIZE if tile.y < 0 else 0,
	)
	return (tile - negative_adjust) / CHUNK_SIZE


static func _chunk_to_tile_origin(chunk: Vector2i) -> Vector2i:
	return chunk * CHUNK_SIZE


func _unload_chunks(chunks: Array[Vector2i]) -> void:
	for chunk in chunks:
		_unload_chunk(chunk)
		$ResourceDeposits.unload_deposits_in_chunk(chunk)


func _unload_chunk(chunk: Vector2i) -> void:
	var rect := chunk_to_rect(chunk)
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			set_cell_item(Vector3i(x, GROUND_LEVEL, y), -1)
	
	_chunks_stats_loaded.erase(chunk)


func _load_chunks(chunks: Array[Vector2i]) -> void:
	for chunk in chunks:
		_load_chunk(chunk)
		$ResourceDeposits.load_deposits_in_chunk(chunk)


func _load_chunk(chunk: Vector2i) -> void:
	var stats = ChunkStats.new()
	var rect := chunk_to_rect(chunk)
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var tile: Tile = _sample_noise_for_tile(x, y)
			stats.count(tile)
			set_cell_item(Vector3i(x, GROUND_LEVEL, y), tile)
	_chunks_stats_loaded[chunk] = stats


func _sample_noise_for_tile(x: int, y: int) -> Tile:
	var noise_value = noise.get_noise_2d(
		x * TILE_TO_NOISE_MULTIPLIER,
		y * TILE_TO_NOISE_MULTIPLIER
	)
	for index in range(tile_gradient_values.size()):
		var value = tile_gradient_values[index]
		if value > noise_value:
			return tile_gradient_keys[index]
	
	return tile_gradient_keys.back()


func _place_resource_deposit(deposit_scene: PackedScene, tile: Vector2i) -> void:
	var world_coords = map_to_local(Vector3i(tile.x, 0, tile.y))
	var deposit: ResourceDeposit = deposit_scene.instantiate()
	deposit.position = world_coords
	$ResourceDeposits.add_child(deposit)


func _refresh_required_chunks() -> void:
	var required_chunks: Array[Vector2i] = [_current_chunk]
	required_chunks.append_array(get_adjacent_chunks(_current_chunk))
	
	_chunks_loaded = required_chunks


func _set_current_chunk(new_chunk: Vector2i) -> void:
	if _current_chunk == new_chunk:
		return
	_current_chunk = new_chunk
	_refresh_required_chunks()
	chunk_distribution_updated.emit(
		_chunks_stats_loaded[new_chunk].tile_distribution
	)


func _set_chunks_loaded(new_chunks_loaded: Array[Vector2i]) -> void:
	var unloaded_chunks: Array[Vector2i] = _chunks_loaded.duplicate()
	var new_chunks: Array[Vector2i] = new_chunks_loaded.duplicate()
	
	for old_chunk_index in range(_chunks_loaded.size() - 1, -1, -1):
		for new_chunk_index in range(new_chunks.size() - 1, -1, -1):
			var old_chunk := unloaded_chunks[old_chunk_index]
			var new_chunk := new_chunks[new_chunk_index]
			if old_chunk == new_chunk:
				unloaded_chunks.remove_at(old_chunk_index)
				new_chunks.remove_at(new_chunk_index)
				break
	
	_chunks_loaded = new_chunks_loaded
	_unload_chunks(unloaded_chunks)
	_load_chunks(new_chunks)
