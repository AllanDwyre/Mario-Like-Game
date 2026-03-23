extends BaseHealthComponent

const STOMPED_SOUND = preload("res://Arts/Audios/SFX/stomp.wav")
const KICK_SOUND = preload("res://Arts/Audios/SFX/kick.wav")

@export var koopa : Koopa

func take_damage(info : DamageInfo):
	super(info)

# Se faire hit, stunt koopa (le transforme en shell)
# Projectile (anyprojectile, kill koopa)
