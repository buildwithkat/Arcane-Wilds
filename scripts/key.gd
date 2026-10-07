extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	pass

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_emerald()
		queue_free() 
