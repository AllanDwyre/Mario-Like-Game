extends CharacterBody2D
class_name EnemyBase

@export var speed : float = 20.0
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var void_raycast: RayCast2D = $VoidRaycast

var direction = 1.0
var died = false
var stunned = false

func _change_direction() -> void :
	# TODO: Add animation of a jumping
	direction *= -1
	void_raycast.position.x = abs(void_raycast.position.x) * direction
	

func _ready() -> void:
	_change_direction()

func _process(delta: float) -> void:
	if position.y > 64:
		queue_free()

func _physics_process(delta: float) -> void:
	if died:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if not stunned and not void_raycast.is_colliding() or is_on_wall():
		_change_direction()
		
	velocity.x = direction * speed
	move_and_slide()

func _on_body_entered(body : Node2D)-> void:
	if not body.is_in_group("Player"):
		return
	
	if  body.velocity.y > 0:
		_onHit()
		body.jump()
	elif not died:
		body.take_damage()

func _onHit():
	died = true
	queue_free()
