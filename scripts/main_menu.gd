extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ready() -> void:
	main_buttons.visible = true
	options.visible = false

func _on_start_game_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_goals.tscn")
	Music_Managers.stop_music()

func _on_settings_btn_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_exit_btn_pressed() -> void:
	get_tree().quit()

func _on_back_options_pressed() -> void:
	_ready()
