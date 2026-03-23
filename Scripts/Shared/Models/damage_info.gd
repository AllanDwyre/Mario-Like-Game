class_name DamageInfo extends RefCounted

enum AttackType {
	HIT,        # collision directe (Goomba, Luigi qui rentre dedans)
	PROJECTILE, # boule de feu, carapace, boulet
	SYSTEM,     # décision du RoundManager
}

enum AttackId {
	NONE,       # HIT basique, STOMP
	FIREBALL,
	ICEBALL,
	SHELL,
	CANNONBALL,
}

var attack_id : AttackId
var attack_type: AttackType
var source: Node2D
var receiver : Node2D

var normal: Vector2:
	get: return (source.global_position - receiver.global_position).normalized()

var is_from_player: bool:
	get: return source is Player

var is_from_enemy: bool:
	get: return source is EnemyBase

func _init(attack_type_: AttackType, source_: Node2D, receiver_: Node2D) -> void:
	attack_type = attack_type_
	source = source_
	receiver = receiver_
