extends CharacterBody2D
class_name OrcEnemy

const SPEED = 50.0
const GRAVITY = 900.0
const ATTACK_RANGE = 40.0

var is_orc_chase: bool = false	

var health = 70
var health_max = 70
var health_min = 0

var dead: bool = false
var taking_damage: bool = false

var damage_to_deal = 13

var dir: Vector2 = Vector2.ZERO
var is_roaming: bool = true

var player: Node2D = null
var can_attack: bool = true
var attack_in_progress: bool = false

# Roaming control
var roam_time: float = 0.0
var roam_duration: float = 0.0
var is_paused: bool = false


func _ready():
	add_to_group("enemy")
	randomize()
	choose_new_direction()
	update_health_bar()


func _physics_process(delta):
	if dead:
		velocity.x = 0
		move_and_slide()
		return

	if !is_on_floor():
		velocity.y += GRAVITY * delta

	handle_combat()
	handle_movement(delta)
	handle_animation()

	move_and_slide()


# -------------------------
# COMBAT
# -------------------------
func handle_combat():
	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= ATTACK_RANGE:
		velocity.x = 0
		if can_attack and !attack_in_progress:
			attack()


func attack():
	attack_in_progress = true
	can_attack = false
	velocity.x = 0

	%AnimatedSprite2D.play("attack_hit")

	await get_tree().create_timer(0.35).timeout

	if player and global_position.distance_to(player.global_position) <= ATTACK_RANGE:
		if player.has_method("take_damage"):
			player.take_damage(damage_to_deal)

	await get_tree().create_timer(0.4).timeout

	attack_in_progress = false
	%AttackCooldown.start()


func _on_attack_cooldown_timeout():
	can_attack = true


# -------------------------
# MOVEMENT
# -------------------------
func handle_movement(delta):
	if attack_in_progress:
		velocity.x = 0
		return

	# CHASE PLAYER
	if is_orc_chase and player:
		var distance = global_position.distance_to(player.global_position)

		if distance > ATTACK_RANGE:
			var direction_to_player = (player.global_position - global_position).normalized()
			dir.x = sign(direction_to_player.x)
			velocity.x = dir.x * SPEED
		else:
			velocity.x = 0
		return

	# RANDOM ROAM
	if is_roaming:
		roam_time += delta

		if roam_time >= roam_duration:
			choose_new_direction()

		if is_paused:
			velocity.x = 0
		else:
			velocity.x = dir.x * SPEED


func choose_new_direction():
	roam_time = 0.0
	roam_duration = randf_range(1.0, 2.5)

	if randf() < 0.3:
		is_paused = true
	else:
		is_paused = false
		dir = choose([Vector2.LEFT, Vector2.RIGHT])


func choose(array):
	return array[randi() % array.size()]


# -------------------------
# ANIMATION
# -------------------------
func handle_animation():
	var anim = %AnimatedSprite2D

	if dead:
		anim.play("dead")
		return

	if attack_in_progress:
		anim.play("attack_hit")
	elif taking_damage:
		anim.play("hurt")
	elif velocity.x != 0:
		anim.play("walk")
	else:
		anim.play("idle")

	if velocity.x < 0:
		anim.flip_h = true
	elif velocity.x > 0:
		anim.flip_h = false


# -------------------------
# DAMAGE
# -------------------------
func take_damage(amount):
	if dead:
		return

	health -= amount
	taking_damage = true
	update_health_bar()

	print("Enemy took damage:", amount)
	print("Current health:", health)

	if health <= health_min:
		dead = true
		%AnimatedSprite2D.play("dead")

		var player_node = get_tree().get_first_node_in_group("player")
		if player_node:
			player_node.add_enemy_kill()

		await get_tree().create_timer(0.8).timeout
		queue_free()
		return
	taking_damage = false


func update_health_bar():
	if has_node("HealthBar"):
		var bar = %HealthBar
		bar.max_value = health_max
		bar.value = health


# -------------------------
# DETECTION
# -------------------------
func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):
		player = body
		is_orc_chase = true


func _on_player_detection_body_exited(body):
	if body == player:
		player = null
		is_orc_chase = false
