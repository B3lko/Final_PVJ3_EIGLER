extends Node


var audio_player: AudioStreamPlayer

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	# Aquí cargas tu AudioStream
	audio_player.stream = preload("res://Assets/Audio/Music/dungeon_theme_2.wav")
	audio_player.bus = "Music"
	audio_player.play()

# Llamar esta función cuando quieras detener el audio, por ejemplo, al entrar en el mapa del juego
func stop_audio():
	if audio_player.is_playing():
		audio_player.stop()

# Llamar esta función si deseas reanudar el audio, por ejemplo, al salir del mapa del juego
func play_audio():
	if not audio_player.is_playing():
		audio_player.play()
