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

func _process(_delta: float) -> void:
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
	if body.is_in_group("Enemies") and body != self:
		_give_damage(body, false)
		return
	
	if not body.is_in_group("Player"):
		return
	
	if  body.velocity.y > 0:
		take_damage(body)
		body.jump()
	elif not died:
		_give_damage(body)

func take_damage(_body : Node2D):
	died = true
	queue_free()
	
func _give_damage(body : Node2D, isPlayer : bool = true):
	if isPlayer:
		body.take_damage(self)
