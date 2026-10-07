extends Area2D
@onready var game_manager: Node = %"Game Manager"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.add_apple()
		queue_free()
