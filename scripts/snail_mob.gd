extends CharacterBody2D

const SPEED = 40
const PATROL_DISTANCE = 80
const GRAVITY = 900

var start_position_x
var direction = -1

var player_in_zone = false
var is_attacking = false
var can_attack = true

var health = 60
var health_max = 60
var health_min = 0

var dead = false
var taking_damage = false

var damage_to_deal = 5

@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var attack_area = $AttackArea
@onready var attack_cooldown = $AttackCooldown


func _ready():
	start_position_x = global_position.x
	health_bar.max_value = health_max
	health_bar.value = health
	health_bar.visible = false


func _physics_process(delta):
	if dead:
		velocity.x = 0
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	if player_in_zone and can_attack:
		attack()
	else:
		patrol()

	move_and_slide()
	


# -------------------------
# PATROL
# -------------------------
func patrol():
	var distance = global_position.x - start_position_x

	if distance > PATROL_DISTANCE:
		direction = -1
	elif distance < -PATROL_DISTANCE:
		direction = 1

	velocity.x = direction * SPEED

	if direction == 1:
		animated_sprite.flip_h = true
	elif direction == -1:
		animated_sprite.flip_h = false

	animated_sprite.play("walk")

# -------------------------
# ATTACK
# -------------------------
func attack():
	is_attacking = true
	can_attack = false
	velocity.x = 0

	animated_sprite.play("attack")

	await get_tree().create_timer(0.2).timeout
	attack_area.monitoring = true

	await get_tree().create_timer(0.2).timeout
	attack_area.monitoring = false

	is_attacking = false
	attack_cooldown.start()


func _on_attack_area_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage_to_deal)


func _on_attack_cooldown_timeout():
	can_attack = true


# -------------------------
# DETECTION
# -------------------------
func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_zone = true


func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_zone = false


# -------------------------
# DAMAGE SYSTEM
# -------------------------
func take_damage(amount):
	if dead:
		return

	health -= amount
	taking_damage = true

	print("Snail Health:", health)

	health_bar.visible = true
	health_bar.value = health

	if health <= health_min:
		die()
		return

	animated_sprite.play("hurt")

	await get_tree().create_timer(0.3).timeout
	taking_damage = false


func die():
	dead = true
	animated_sprite.play("dead")
	await get_tree().create_timer(1.0).timeout
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_enemy_kill()
	queue_free()
