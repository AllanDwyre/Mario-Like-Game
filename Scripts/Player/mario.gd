class_name Mario extends CharacterBody2D

const JUMP_SOUND = preload("res://Arts/Audios/Mario SFX/nsmb_jump.wav")
const HIT_SOUND = preload("res://Arts/Audios/Mario SFX/change_small.wav")
const DEATH_SOUND = preload("res://Arts/Audios/Mario SFX/nsmb_death.wav")

@export var speed : float = 150.0
@export var jump_force : float = 150.0

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

# TODO: [ ]Coyote + buffered jumps
# TODO: [ ]better movement feeling
# TODO: [ ]level selector + transition effect (death + win)


var _size = "small"
var died = false
var collision_sizes = {
	"small": Vector2(6, 16),
	"big": Vector2(8, 32)
}
var can_move = true

func get_size() -> String :
	return _size
	
func take_damage(_from : Node2D ):
	if _size == "small":
		kill()
	else:
		SoundManager.play_sound(HIT_SOUND)
		_set_size("small")

func _ready() -> void:
	_update_collision()

func _process(_delta: float) -> void:
	position.x = max(position.x, -256) # on clamp le player
	
	if position.y > 48 :
		kill()
		
func play_anim(anim_name : String, flip : bool = false) -> void :
	anim.play(_size + "_" + anim_name)
	anim.flip_h = flip

func _set_size(size : String):
	_size = size
	_update_collision()
	
func power_up():
	SoundManager.play_sound(load("res://Arts/Audios/Mario SFX/nsmb_power-up.wav"))
	_set_size("big")

func kill() -> void :
	if died:
		return
	died = true
	can_move = false
	GameSignals.player_died.emit()
	SoundManager.pause_music()
	anim.play("death")
	SoundManager.play_sound(DEATH_SOUND)
	var tween = get_tree().create_tween()
	tween.tween_property(anim, "position:y", anim.position.y - 64, .5)
	tween.tween_property(anim, "position:y", 64, 1)

func _update_collision() -> void :
	collision_shape.shape.set_size(collision_sizes[_size])
	
func jump():
	velocity.y = -jump_force
	SoundManager.play_sound(JUMP_SOUND)
	
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
		new_anim = _size + "_jump"
	elif direction != 0:
		new_anim = _size + "_run"
	else:
		new_anim = _size + "_idle"

	if anim.animation != new_anim:
		anim.play(new_anim)

	move_and_slide()
	detect_collision()

func detect_collision():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("Interactables"):
			collider.interact(self)
		
