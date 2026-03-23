extends Node
class_name BaseHealthComponent

signal depleted
signal replenished

@export var initial_health: int = 1
var _health

func _ready() -> void:
	_health = initial_health

func take_damage(info : DamageInfo):
	if info.attack_type == info.AttackType.SYSTEM:
		depleted.emit()
		return
	pass

func reset_health():
	_health = initial_health
	replenished.emit()
