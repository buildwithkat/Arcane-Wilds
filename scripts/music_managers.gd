extends Node

@onready var music_player: AudioStreamPlayer2D = $AudioStreamPlayer

func play_music(stream: AudioStream):
	music_player.stream = stream
	music_player.stream.loop = true
	music_player.play()

func stop_music():
	music_player.stop()
