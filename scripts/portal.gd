extends Area2D

var player: CharacterBody2D = null
var door_opened := false
var player_in_range := false

func _ready():
	set_process(true) 

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		print("Pressed E")
		try_open()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_in_range = true
		print("Player entered portal area")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
		player_in_range = false
		print("Player exited portal area")

func try_open():
	if door_opened:
		return
		
	if player == null:
		print("No player reference")
		return

	# Safety check: make sure function exists
	if not player.has_method("has_completed_goals"):
		print("Player missing has_completed_goals()")
		return

	if player.has_completed_goals():
		door_opened = true
		print("Portal opened!")

		get_tree().change_scene_to_file("res://scenes/victory.tscn")


	else:
		print("Objectives not complete!")
