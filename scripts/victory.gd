extends Control
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer
@export var main_menu_music: AudioStream
@export var level1_music: AudioStream
func _ready():
	# Stop global background music
	Music_Managers.stop_music()  # global singleton
	# Play win/lose sound
	sfx_player.play()

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
	if level1_music:
		Music_Managers.play_music(level1_music)
func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	if main_menu_music:
		Music_Managers.play_music(main_menu_music)
func _on_exit_pressed() -> void:
	get_tree().quit()
