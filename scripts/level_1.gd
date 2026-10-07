extends Node2D

@export var level1_music: AudioStream
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Music_Managers.play_music(level1_music)
	level1_music.loop = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
