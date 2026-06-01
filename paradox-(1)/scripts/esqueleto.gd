extends CharacterBody2D

const SPEED = 60.0
const ATTACK_DISTANCE = 55.0
const GRAVITY = 900.0

const KNOCKBACK_FORCE = 250.0
const KNOCKBACK_TIME = 0.25

var hp = 7
var attacking = false
var can_attack = true
var knockback_timer = 0.0

@onready var sprite = $AnimatedSprite2D


func _ready():

	add_to_group("enemy")

	sprite.play("idle")


func _physics_process(delta):

	if !is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0


	var players = get_tree().get_nodes_in_group("player")

	if players.is_empty():
		return


	# ---------- PLAYER MAIS PRÓXIMO ----------
	var target = players[0]

	for p in players:

		if global_position.distance_to(
		p.global_position) < \
		global_position.distance_to(
		target.global_position):

			target = p


	# ---------- KNOCKBACK ----------
	if knockback_timer > 0:

		knockback_timer -= delta

	else:

		if !attacking:

			var dir_x = target.global_position.x - global_position.x

			var distance = abs(dir_x)

			sprite.flip_h = dir_x > 0


			if distance <= ATTACK_DISTANCE:

				attack(target)

			else:

				velocity.x = sign(dir_x) * SPEED


	if !attacking:

		if abs(velocity.x) > 0:
			sprite.play("andar")
		else:
			sprite.play("idle")


	move_and_slide()


func attack(target):

	if !can_attack:
		return

	can_attack = false
	attacking = true

	velocity.x = 0

	sprite.play("ataque")

	var dist = global_position.distance_to( target.global_position)

	if dist <= ATTACK_DISTANCE + 10:

		var dir = target.global_position - global_position

		target.take_damage(1, dir)

	await sprite.animation_finished

	attacking = false

	await get_tree().create_timer(1.2).timeout

	can_attack = true


func take_damage(damage, knockback_direction):

	hp -= damage

	# FLASH HIT
	var cor_original = modulate

	modulate = Color(1,0,0)

	await get_tree().create_timer(0.10).timeout

	modulate = cor_original


	# KNOCKBACK
	velocity.x = knockback_direction.normalized().x * 250

	velocity.y = -150

	if hp <= 0:
		die()


func die():

	sprite.play("morte")

	set_physics_process(false)

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred(
			"disabled",
			true)

	await sprite.animation_finished

	queue_free()
