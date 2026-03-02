extends Node

const MAX_PLAYERS = 10
const TARGET_PLAYERS = 5

var audioPool : Pooling
var musicPlayer : AudioStreamPlayer

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	audioPool = Pooling.new(_onCreate,_onTake,_onReturn,_onDestroy, TARGET_PLAYERS, MAX_PLAYERS)
	musicPlayer = _onCreate()
	musicPlayer.bus = "Music"
	
	Performance.add_custom_monitor("Audio/AudioStreamPlayerPooled", func (): return audioPool.count_all)
	Performance.add_custom_monitor("Audio/AudioStreamPlayerActive", func (): return audioPool.count_active)
	Performance.add_custom_monitor("Audio/AudioStreamPlayerInactive", func (): return audioPool.count_inactive)
	
	set_music_volume(Settings.get_setting("volume_music"))
	set_sfx_volume(Settings.get_setting("volume_sfx"))

#region Pooling Callables
func _onCreate() -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = "SFX"
	return player

func _onTake(player : AudioStreamPlayer):
	player.finished.connect(func() : audioPool.release(player), CONNECT_ONE_SHOT)

func _onReturn(player : AudioStreamPlayer):
	player.stop()
	if player.finished.is_connected(audioPool.release):
		player.finished.disconnect(audioPool.release)

func _onDestroy(player : AudioStreamPlayer):
	player.queue_free()
#endregion

func play_sound(sound : AudioStream, volume : float = 1.0):
	var player : AudioStreamPlayer = audioPool.take()
	player.stream = sound
	player.volume_db = linear_to_db(volume)
	player.play()

func play_music(sound : AudioStream, volume : float = 1.0):
	musicPlayer.stream = sound
	musicPlayer.volume_db = linear_to_db(volume)
	musicPlayer.play()

func pause_music():
	musicPlayer.stop()

## Renvoie l'intensité du Bus [0;1]
func get_sfx_volume() -> float:
	return AudioServer.get_bus_volume_linear(SFX_BUS_ID)
	
## Renvoie l'intensité du Bus [0;1]
func get_music_volume() -> float:
	return AudioServer.get_bus_volume_linear(MUSIC_BUS_ID)
	
func set_sfx_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(volume))
	AudioServer.set_bus_mute(SFX_BUS_ID, volume < .05)

func set_music_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(volume))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, volume < .05)
