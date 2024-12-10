extends Node3D

enum EnemyType {
	CUBOID,
	DEATH_SPHERE,
	PYRIMIDIC_DECIMATOR,
}

# Outer in order of Tile from procedural_ground.gd, inner in order of EnemyType.
const ENEMY_SPAWN_DISTRIBUTIONS = [
	[0.2, 0.8, 0.0],
	[0.8, 0.2, 0.0],
	[0.8, 0.8, 0.2],
	[1.0, 1.0, 2.0],
]
const SPAWN_DISTANCE = 50.0
const GRACE_PERIOD = 0.5
const MINIMUM_SPAWN_DIFF = 0.5
const MAXIMUM_SPAWN_DIFF = 7.0

@export var enemies: Array[PackedScene]
@export var enemy_manager: EnemyManager

@onready var spawn_timer := Timer.new()

# Order of EnemyType
var current_enemy_distribution := [0.5, 0.5, 0.0]


func _ready() -> void:
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.one_shot = true
	spawn_timer.wait_time = GRACE_PERIOD
	spawn_timer.start()


func _on_current_chunk_tile_distribution_updated(distribution: Dictionary) -> void:
	var new_enemy_distribution := [0.0, 0.0, 0.0]
	for tile in distribution.keys():
		var tile_percent: float = distribution[tile]
		for enemy_type in EnemyType.values():
			new_enemy_distribution[enemy_type] += (
				tile_percent * ENEMY_SPAWN_DISTRIBUTIONS[tile][enemy_type]
			)
	
	current_enemy_distribution = new_enemy_distribution


func _on_spawn_timer_timeout() -> void:
	var enemy_type: EnemyType = Distributions.sample_from_distribution(
		current_enemy_distribution
	) as EnemyType
	var enemy_direction: float = randf_range(0, TAU)
	var enemy_relative_position: Vector3 = (
		Vector3.FORWARD.rotated(Vector3.UP, enemy_direction) * SPAWN_DISTANCE
	)
	var enemy: Enemy = enemies[enemy_type].instantiate()
	# Technically we aren't accounting for rotation, but since it's random,
	# it doesn't really matter.
	enemy_manager.add_enemy(enemy)
	enemy.global_position = global_position + enemy_relative_position
	spawn_timer.wait_time = randf_range(MINIMUM_SPAWN_DIFF, MAXIMUM_SPAWN_DIFF)
	spawn_timer.start()
