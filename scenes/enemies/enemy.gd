class_name Enemy
extends Area3D

signal request_transform(transform: EnemyManager.EnemyTransformName)

@export var speed: float = 2.25

@onready var state_machine: EnemyStateMachine = $States
@onready var animation: AnimationPlayer = $Animation
@onready var navigation: NavigationAgent3D = $Navigation

# Set externally by EnemyManager before _ready
var get_target_position: Callable


func _ready() -> void:
	state_machine.initialize(self)
