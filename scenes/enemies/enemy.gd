class_name Enemy
extends Area3D

# These signals are emitted by states.
@warning_ignore("unused_signal")
signal request_transform(transform: EnemyManager.EnemyTransformName)
@warning_ignore("unused_signal")
signal attacked_watchtower(damage: int)
@warning_ignore("unused_signal")
signal defeated

const DESPAWN_TIMER = 20
const DESPAWN_PREVENTION_RADIUS = 50

@export var speed: float = 2.25
@export var max_health: int = 25
@export var damage: float = 45

@onready var state_machine: EnemyStateMachine = $States
@onready var animation: AnimationPlayer = $Animation
@onready var navigation: NavigationAgent3D = $Navigation
@onready var hurt_sound: AudioStreamPlayer = $Hurt
@onready var despawn_timer = Timer.new()

var health: int = max_health : set = _set_health

# Set externally by EnemyManager before _ready
var enemy_transform: EnemyTransform

var disable_hurt_anim := false
var can_despawn := false

func _ready() -> void:
	state_machine.initialize(self)
	despawn_timer.wait_time = DESPAWN_TIMER
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(func():
		can_despawn = true
		attempt_despawn()
	)
	add_child(despawn_timer)
	despawn_timer.start()


func take_damage(amount: int) -> void:
	health -= amount
	if disable_hurt_anim:
		return
	$Animation.play("hurt")
	$Hurt.play()


func get_target_position() -> Vector3:
	return enemy_transform.get_target_position()


# This is so enemies can play an animation before calling queue_free without
# towers still attacking them.
func force_untarget() -> void:
	$Collision.set_deferred("disabled", true)


func attempt_despawn() -> void:
	if can_despawn and not $OffScreen.is_on_screen():
		despawn()


func despawn() -> void:
	queue_free()


func _set_health(new_health: int) -> void:
	# There is not any healing planned yet, but I wanted to add this in case
	# it comes about eventually.
	health = clampi(new_health, 0, max_health)
	if health == 0:
		state_machine.change_state_to(EnemyStateMachine.State.DEFEATED)
