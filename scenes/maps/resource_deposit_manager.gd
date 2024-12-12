extends Node3D

# Yes this could be ConsumablePool.Consumable, but this allows for different
# deposits with the same consumable - for example, "large" deposits.
enum Deposit {
	LUMBER,
	COAL,
	IRON,
	GOLD,
}

# Arrays in order of Deposit enum.
const BIOME_DEPOSIT_TYPE_WEIGHTS = {
	Ground.Tile.GRASS: [0.6, 0.4, 0.0, 0.0],
	Ground.Tile.FOREST: [0.9, 0.1, 0.0, 0.0],
	Ground.Tile.MOUNTAIN: [0.0, 0.5, 0.4, 0.1],
	Ground.Tile.MAGMA: [0.0, 0.1, 0.5, 0.4],
}

const MAX_AMOUNT_PER_CHUNK = 4
# This is assumed to be less than the size of a chunk in meters.
const MINIMUM_DISTANCE_BETWEEN = 30 # in meters, not tiles (2m wide each)
const MAX_SPAWN_ATTEMPS_BEFORE_SKIP = 5

@export var resource_deposits: Array[PackedScene]

@onready var ground: Ground = get_parent()

# Chunk (Vector2i) : Array[ResourceDeposit]
var deposits = {}


func load_deposits_in_chunk(chunk: Vector2i) -> void:
	if not deposits.has(chunk):
		_generate_deposits_for_chunk(chunk)
	
	for deposit in deposits[chunk]:
		_load_deposit(deposit)


func unload_deposits_in_chunk(chunk: Vector2i) -> void:
	for deposit in deposits[chunk]:
		_unload_deposit(deposit)


func _generate_deposits_for_chunk(chunk: Vector2i) -> void:
	var spawn_positions = _generate_spawn_positions(chunk)
	# This is so _create_deposit_at can assume there is already a list.
	deposits[chunk] = []
	
	
	for deposit_position in spawn_positions:
		var tile: Ground.Tile = ground.get_cell_item(
			ground.local_2d_to_tile_3d(deposit_position)
		) as Ground.Tile
		var distribution: Array = BIOME_DEPOSIT_TYPE_WEIGHTS[tile]
		
		var type: Deposit = Distributions.sample_from_distribution(
			distribution
		) as Deposit
		
		_create_deposit_at(type, deposit_position, chunk)


func _generate_spawn_positions(chunk: Vector2i) -> Array[Vector2]:
	var chunk_rect := Ground.chunk_to_rect(chunk)
	var chunk_rect_local_origin := ground.tile_2d_to_local_2d(chunk_rect.position)
	var chunk_rect_local_end := ground.tile_2d_to_local_2d(chunk_rect.end - Vector2i.ONE)
	var relevant_deposit_positions: Array[Vector2]
	for adj_chunk in Ground.get_adjacent_chunks(chunk):
		if not deposits.has(adj_chunk):
			continue
		for deposit in deposits[adj_chunk]:
			relevant_deposit_positions.append(
				Vector2(deposit.position.x, deposit.position.z)
			)
	
	var positions: Array[Vector2] = []
	
	var failed_attemps := 0
	while (
		failed_attemps < MAX_SPAWN_ATTEMPS_BEFORE_SKIP
		and positions.size() < MAX_AMOUNT_PER_CHUNK
	):
		var deposit_position = Vector2(
			randf_range(chunk_rect_local_origin.x, chunk_rect_local_end.x),
			randf_range(chunk_rect_local_origin.y, chunk_rect_local_end.y)
		)
		
		var too_close := false
		for relevant_position in relevant_deposit_positions:
			if relevant_position.distance_to(deposit_position) < MINIMUM_DISTANCE_BETWEEN:
				too_close = true
				break
		
		if not too_close:
			positions.append(deposit_position)
			relevant_deposit_positions.append(deposit_position)
	
	return positions


func _create_deposit_at(
	type: Deposit,
	deposit_position: Vector2,
	chunk: Vector2i
) -> void:
	var deposit: ResourceDeposit = resource_deposits[type].instantiate()
	deposit.position = ground.local_2d_to_local_3d(deposit_position)
	deposit.used.connect(func(): _on_deposit_used(deposit, chunk))
	add_child(deposit)
	deposits[chunk].append(deposit)


func _on_deposit_used(deposit: ResourceDeposit, chunk: Vector2i) -> void:
	deposits[chunk].remove_at(deposits[chunk].find(deposit))
	# We don't then remove the chunk key from deposits because it would
	# regerate deposits in that instance.
	print("removed " + str(deposit))


func _load_deposit(deposit: ResourceDeposit) -> void:
	deposit.show()
	deposit.process_mode = Node.PROCESS_MODE_INHERIT


func _unload_deposit(deposit: ResourceDeposit) -> void:
	deposit.hide()
	deposit.process_mode = Node.PROCESS_MODE_DISABLED
