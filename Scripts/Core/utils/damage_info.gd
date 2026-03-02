extends RefCounted
class_name DamageInfo

# Some damage can be decided from the object ? 
# like the Ice ball will freeze the entity 
# like the Fire ball will instant kill any entity

# NOTE : How to handle this ??

enum DamageType{
	Stomped,
	Projectile, # Death by a projectile like the canon, shell, fireball, iceball etc...
	System, # Death decided by the system
}

var type: DamageType
var source: Node2D
var receiver: Node2D

## get normal from the receiver to the source
var normal: Vector2 :
	get() : return (source.global_position - receiver.global_position).normalized()

func _init(damage_type_: DamageType = DamageType.Stomped,
		source_: Node2D = null, receiver_: Node2D = null
	):
	type = damage_type_
	source = source_
	receiver = receiver_
