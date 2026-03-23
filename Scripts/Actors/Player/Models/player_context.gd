extends RefCounted
class_name PlayerContext

var player : Player
## Desactivate all movement and process
var can_move : bool = true

var direction : float
var run_pressed : bool

#region Jump Contexts
var jump_pressed : bool
var has_jumped : bool
var has_wall_jumped : bool
var jump_released : bool

## represent the countdown where your jump is still requested for the landing
var buffered_timer : float = 0.0
## represent the time in the air where you can still jump
var coyotte_timer : float = 0.0
#endregion

var p_meter : float = 0.0

var is_grounded : bool

var velocity : Vector2 :
	get : return player.velocity
	set(value) : player.velocity = value

func _init(player_ : Player) -> void:
	player = player_
