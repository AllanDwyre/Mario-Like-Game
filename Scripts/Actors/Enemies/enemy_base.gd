@abstract
extends Entity
class_name EnemyBase

@export var speed : float = 20.0
@onready var void_raycast: RayCast2D = $VoidRaycast

const COLLISION_NORMAL_THRESHOLD = 0.5
var direction = 1.0

var reset_initialised : bool = false
var reset_position : Vector2

func _ready() -> void:
	_change_direction()

func _process(_delta: float) -> void:
	if position.y > 64:
		queue_free()
		# call instant kill of itslef by using health component

func reset_entity():
	global_position = reset_position

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif not reset_initialised:
		reset_initialised= true
		reset_position = global_position
		
	# Si ce n'est ni un enemi ni un player
	if edge_collision() or is_on_wall():
		_change_direction()
	
	velocity.x = direction * speed
	move_and_slide()

func edge_collision():
	return not void_raycast.is_colliding() and is_on_floor()

#region Legacy Logic
func get_collision_normal(body : Node2D) -> Vector2:
	return (body.global_position - global_position).normalized()

## Gère chacune des collisions
func _handle_collision(body : Node2D):
	# si on collide un autre enemy :
	if body is EnemyBase:
		_on_enemy_collision(body)
		return
		
	# si on collide avec un player, et que l'angle de collision est bon,
	# on lui inflige des damages
	if can_take_damage(body):
		# player is above us, we take damage
		take_damage(body)
	elif body.has_method("take_damage"):
		# player hits us from side/below, they take damage
		_on_inflict_damage(body)
	
@abstract
func take_damage(body)

func can_take_damage(from : Node2D):
	var normal = get_collision_normal(from)
	var is_stomped = normal.y < -.3
	# faudra l'améliorer via un struct de context du damage : player vs projectile vs manager code
	if from is Player:
		return is_stomped
	return true

func _on_inflict_damage(to : Node2D) -> void :
	to.take_damage(self)
	
func _on_enemy_collision(_body : Node2D) -> void :
	_change_direction()

#endregion
func _change_direction() -> void :
	direction *= -1
	void_raycast.position.x = abs(void_raycast.position.x) * direction
