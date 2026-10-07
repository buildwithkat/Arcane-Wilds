extends CharacterBody2D
class_name Boar_Enemy

# -------------------
# MOVEMENT SETTINGS
# -------------------
const PATROL_SPEED = 80.0
const CHASE_SPEED = 170.0
const GRAVITY = 900.0
const PATROL_DISTANCE = 120.0
const ATTACK_RANGE = 45.0

var start_x
var patrol_direction = -1

# -------------------
# PLAYER
# -------------------
var player: Node2D = null
var is_chasing = false

# -------------------
# ATTACK
# -------------------
var attack_in_progress = false
var can_attack = true
var damage_to_deal = 18

# -------------------
# HEALTH
# -------------------
var health = 90
var health_max = 90
var health_min = 0
var dead = false
var taking_damage = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var attack_cooldown = $AttackCooldown

# ------------------------------------------------

func _ready():
	start_x = global_position.x
	attack_area.monitoring = false
	add_to_group("enemy")

func _physics_process(delta):

	if dead:
		velocity.x = 0
		move_and_slide()
		return

	# Gravity
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	# CHASE LOGIC
	if player and is_chasing:
		var distance = global_position.distance_to(player.global_position)

		if distance <= ATTACK_RANGE and can_attack and !attack_in_progress:
			attack()
		elif !attack_in_progress:
			chase()
	else:
		if !attack_in_progress:
			patrol()

	handle_animation()
	move_and_slide()

# ------------------------------------------------
# PATROL 
# ------------------------------------------------
func patrol():

	var distance = global_position.x - start_x

	if distance > PATROL_DISTANCE:
		patrol_direction = -1
	elif distance < -PATROL_DISTANCE:
		patrol_direction = 1

	velocity.x = patrol_direction * PATROL_SPEED
	animated_sprite.flip_h = patrol_direction > 0

# ------------------------------------------------
# CHASE
# ------------------------------------------------
func chase():
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * CHASE_SPEED
	animated_sprite.flip_h = direction > 0

# ------------------------------------------------
# PLAYER DETECTION
# ------------------------------------------------
func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):
		player = body
		is_chasing = true

func _on_player_detection_body_exited(body):
	if body == player:
		player = null
		is_chasing = false

# ------------------------------------------------
# ATTACK
# ------------------------------------------------
func attack():

	attack_in_progress = true
	can_attack = false
	velocity.x = 0

	animated_sprite.play("attack")
	attack_area.monitoring = true

	await get_tree().create_timer(0.25).timeout

	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(damage_to_deal)

	attack_area.monitoring = false

	await get_tree().create_timer(0.4).timeout

	attack_in_progress = false
	attack_cooldown.start()

func _on_attack_cooldown_timeout():
	can_attack = true

# ------------------------------------------------
# DAMAGE SYSTEM
# ------------------------------------------------
func take_damage(amount):

	if dead:
		return

	health -= amount
	taking_damage = true

	if health <= health_min:
		die()
		return

	await get_tree().create_timer(0.3).timeout
	taking_damage = false

func die():
	dead = true
	animated_sprite.play("dead")

	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.add_enemy_kill()

	await get_tree().create_timer(1.0).timeout
	queue_free()

# ------------------------------------------------
# ANIMATION
# ------------------------------------------------
func handle_animation():

	if dead:
		return

	if attack_in_progress:
		animated_sprite.play("attack")
	elif taking_damage:
		animated_sprite.play("hurt")
	elif player and is_chasing:
		animated_sprite.play("run")
	else:
		animated_sprite.play("walk")
