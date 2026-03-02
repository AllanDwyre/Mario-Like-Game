extends CharacterBody2D
class_name Player 

#NOTE: this scripts used this documentation to make the movement :
# https://www.youtube.com/watch?v=u2fwxuHZXIA
#NOTE: Some inspiration for the future game :
#https://www.youtube.com/watch?v=v6MBG5pN790
#NOTE: Some inspiration for the future game :
# Celeste is very good game
#NOTE: The future game will feature, ninja (with colorfull skin) attacking tomato (as Goomba) etc..
# The ninja will get movment from the inspiration video

const HIT_SOUND = preload("res://Arts/Audios/Mario SFX/change_small.wav")
const DEATH_SOUND = preload("res://Arts/Audios/Mario SFX/nsmb_death.wav")
const COLLISION_NORMAL_THRESHOLD = 0.5

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var player_info : PlayerInfo

var context : PlayerContext
@export var invincible : bool
@export var movement : Movement
@export var input : InputHandler

enum PlayerSize {
	Small,
	Big,
}
var _size : PlayerSize = PlayerSize.Small

var is_dead : bool
var has_been_hitted : bool

func _ready() -> void:
	set_process(false)
	set_process_input(false)
	set_physics_process(false)

func setup_player(info : PlayerInfo):
	print("player {info.device_id} setup !")
	player_info = info
	
	context = PlayerContext.new(self)
	input.set_up(context, info)
	movement.set_up(self, context)
	
	_update_collision()
	set_process(true)
	set_process_input(true)
	set_physics_process(true)

func _process(delta: float) -> void:
	movement.Update(delta)
	
	position.x = max(position.x, -256) # on clamp le player
	if position.y > 64 :
		kill()

func _physics_process(delta: float) -> void:
	if is_fully_blocked():
		print("Player is stuck")
		unstuck()
		return
	
	movement.PhysicUpdate(delta)
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var col = collision.get_collider()
		if col.is_in_group("Interactables"):
			col.interact(self, collision)

func is_fully_blocked():
	return is_on_wall() and is_on_ceiling()

func unstuck():
	for i in range(10):
		global_position.y -= 1
		if not test_move(transform, Vector2.ZERO):
			return
#region Size methods
func set_size(size : PlayerSize):
	_size = size
	play_anim(sprite.animation.split("_")[1])
	_update_collision()
	
func get_size() -> String:
	return PlayerSize.keys()[_size].to_lower()

func _update_collision() -> void :
	var collision_sizes = {
		PlayerSize.Small : Vector2(10, 16),
		PlayerSize.Big : Vector2(12, 32)
	}
	(collision_shape.shape as RectangleShape2D).size = collision_sizes[_size]
#endregion

func play_anim(anim_name : String, flip : bool = false) -> void :
	sprite.play(get_size() + "_" + anim_name)
	sprite.flip_h = flip

func set_can_move(can : bool):
	input.enable(can)

func get_collision_normal(body : Node2D) -> Vector2:
	return (body.global_position - global_position).normalized()

## This function handle only when the player it another player
func detect_collision(body : Node2D):
	if body == self or body is not Player:
		return
	var player = body as Player
	var normal = get_collision_normal(player)
	var is_stomped = normal.y < COLLISION_NORMAL_THRESHOLD
	
	if is_stomped:
		print(player.player_info.device_id, "hit player", player_info.device_id)
		player.player_info.joy_vibration(1,0,1)
		#take_damage(player)
		player.movement.ForceJump()
	

#region Damage handling
func take_damage(_from : Node2D ):
	if invincible:
		return
	
	if has_been_hitted:
		return
	has_been_hitted = true
	
	if _size == PlayerSize.Small:
		kill()
	else:
		SoundManager.play_sound(HIT_SOUND)
		set_size(PlayerSize.Small)
		
	await get_tree().create_timer(2).timeout
	
	has_been_hitted = false

func kill() -> void :
	if is_dead:
		return
	
	collision_shape.set_deferred("disabled", true)
	set_physics_process(false)
	set_process(false)
	player_info.joy_vibration(1,1,1)
	is_dead = true
	context.can_move = false
	GameSignals.player_died.emit()
	SoundManager.pause_music()
	sprite.play("death")
	SoundManager.play_sound(DEATH_SOUND)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:y", global_position.y - 64, .5)
	tween.tween_property(self, "global_position:y", 64, 1)
	
	await tween.finished
	
	# return a signal
	get_tree().reload_current_scene()
#endregion
