extends Node

const MAX_PLAYERS = 15
const TARGET_PLAYERS = 5


var audioPool : Pooling
var musicPlayer : AudioStreamPlayer

func _ready() -> void:
	audioPool = Pooling.new(_onCreate,_onTake,_onReturn,_onDestroy, TARGET_PLAYERS, MAX_PLAYERS)
	musicPlayer = _onCreate()
	musicPlayer.bus = "Music"

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
	player.volume_db = volume
	player.play()

func play_music(sound : AudioStream, volume : float = 1.0):
	musicPlayer.stream = sound
	musicPlayer.volume_db = volume
	musicPlayer.play()

func pause_music():
	musicPlayer.stop()

func set_sfx_volume(volume_db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), volume_db)

func set_music_volume(volume_db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume_db)
