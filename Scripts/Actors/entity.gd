@abstract
class_name Entity
extends CharacterBody2D

func _ready() -> void:
	if GameManager.current_gamemode == GameManager.EGameMode.Versus:
		add_child(WrapComponent.new())
