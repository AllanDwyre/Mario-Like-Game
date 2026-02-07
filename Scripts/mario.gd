extends CharacterBody2D

@export var speed : float = 150.0
@export var jump_force : float = 150.0

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

# TODO: Coyote + buffered jumps
# TODO: better movement feeling
# TODO: better anim with flip option to the play public method
# TODO: powerups in the level
# TODO: sounds
# TODO: point system
# TODO: coins + breakable
# TODO: level selector + transition effect (death + win)


var size = "small"
var died = false
var collision_sizes = {
	"small": Vector2(6, 16),
	"big": Vector2(8, 32)
}
var can_move = true

func take_damage():
	if size == "small":
		_die()
	else:
		size = "small"

func _ready() -> void:
	_update_collision()

func _process(delta: float) -> void:
	position.x = max(position.x, -256) # on clamp le player
	
	if position.y > 48 :
		_die()
		
func play_anim(anim_name : String) -> void :
	anim.play(size + "_" + anim_name)

func _die() -> void :
	if died:
		return
	died = true
	can_move = false
	anim.play("death")
	var tween = get_tree().create_tween()
	tween.tween_property(anim, "position:y", anim.position.y - 64, .5)
	tween.tween_property(anim, "position:y", 64, 1)
	print("Player died")

func _update_collision() -> void :
	collision_shape.shape.set_height(collision_sizes[size].y)
	collision_shape.shape.set_radius(collision_sizes[size].x)
	collision_shape.position.y = -collision_sizes[size].y / 2.0
	
func jump():
	velocity.y = -jump_force
	
func _physics_process(delta: float) -> void:
	if not can_move:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
		anim.flip_h = sign(direction) < 0 
	else:
		velocity.x = 0

	var new_anim = ""
	if not is_on_floor():
		new_anim = size + "_jump"
	elif direction != 0:
		new_anim = size + "_run"
	else:
		new_anim = size + "_idle"

	if anim.animation != new_anim:
		anim.play(new_anim)

	move_and_slide()
