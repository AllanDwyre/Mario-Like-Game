extends CharacterBody2D

var direction = 1
const speed = 40
var active = false

@onready var player_cast = $ShapeCast2D
func activate():
	active = true

func _process(_delta: float) -> void:
	if active and player_cast.is_colliding()  :
		_on_player_hit(player_cast.get_collider(0))

func _physics_process(delta: float) -> void:
	if not active:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_wall():
		direction *= -1
	position.x += delta * speed * direction
	move_and_slide()

func change_direction():
	direction *= -1
	

func _on_player_hit(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.power_up()
		GameSignals.add_score.emit(300, global_position)
		queue_free()
