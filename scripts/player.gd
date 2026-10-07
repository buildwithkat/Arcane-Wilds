extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
@onready var ui: CanvasLayer = %UI
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

# -------------------------
# STATS
# -------------------------
var health := 100
var health_max := 100
var health_min := 0

var dead := false
var taking_damage := false
var invulnerable := false

# -------------------------
# COMBAT
# -------------------------
var is_attacking := false
var can_attack := true
var damage_to_deal := 20
var facing_right := true  
# -------------------------
# OBJECTIVES
# -------------------------
var has_key := false
var apple_count := 0
var apple_counter;
var emerald_count := 0
var enemies_killed := 0

func _ready():
	add_to_group("player")
	attack_area.monitoring = false
	apple_counter = ui.get_node("Label")

func _physics_process(delta):

	if dead:
		velocity.x = 0
		move_and_slide()
		return

	# Attack
	if Input.is_action_just_pressed("attack") and can_attack:
		attack()

	# Gravity
	if !is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")

	if direction > 0:
		animated_sprite_2d.flip_h = false
		attack_area.scale.x = 1
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		attack_area.scale.x = -1

	if is_attacking:
		velocity.x = 0
	else:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	handle_animation(direction)
	move_and_slide()

# -------------------------
# OBJECTIVE FUNCTIONS
# -------------------------
func collect_key():
	has_key = true
	print("Key collected!")

func add_apple():
	apple_count += 1
	print("Apples:", apple_count)
	apple_counter.text = str(apple_count)

func add_emerald():
	emerald_count += 1
	print("Emerald collected!")

func add_enemy_kill():
	enemies_killed += 1
	print("Enemies defeated:", enemies_killed)

func has_completed_goals() -> bool:
	return apple_count >= 50 \
		and emerald_count >= 1 \
		and enemies_killed >= 9

func restore_health():
	health = health_max

# -------------------------
# ANIMATION
# -------------------------
func handle_animation(direction):
	if is_attacking:
		animated_sprite_2d.play("attack")
	elif taking_damage:
		animated_sprite_2d.play("hurt")
	elif !is_on_floor():
		animated_sprite_2d.play("jump")
	elif direction == 0:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("run")

# -------------------------
# ATTACK SYSTEM
# -------------------------
func attack():
	is_attacking = true
	can_attack = false
	velocity.x = 0

	animated_sprite_2d.play("attack")

	await get_tree().create_timer(0.15).timeout
	attack_area.monitoring = true

	await get_tree().create_timer(0.15).timeout
	attack_area.monitoring = false

	is_attacking = false
	%AttackCooldown.start()

func _on_attack_area_body_entered(body):
	if is_attacking and body.has_method("take_damage"):
		body.take_damage(damage_to_deal)

func _on_attack_cooldown_timeout():
	can_attack = true

# -------------------------
# DAMAGE SYSTEM
# -------------------------
func take_damage(amount):

	if invulnerable or dead:
		return

	health -= amount
	taking_damage = true
	invulnerable = true

	if health <= health_min:
		die()
		return

	await get_tree().create_timer(0.3).timeout
	taking_damage = false

	await get_tree().create_timer(0.5).timeout
	invulnerable = false

func die():
	if dead:
		return

	dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)

	animated_sprite_2d.play("dead")

	await get_tree().create_timer(1.0).timeout

	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
