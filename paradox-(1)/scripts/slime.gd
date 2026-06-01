extends CharacterBody2D

const SPEED = 80.0
const GRAVITY = 980.0

var hp = 3
var direction = 1
var player = null

var knockback_time = 0.0

@onready var sprite = $AnimatedSprite2D


func _ready():
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta):

	if !is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0


	# ---------- KNOCKBACK ----------
	if knockback_time > 0:

		knockback_time -= delta

	else:

		if player:

			var dir_to_player = player.global_position.x - global_position.x

			if dir_to_player > 0:
				direction = 1
			else:
				direction = -1

			velocity.x = direction * SPEED

			if sprite:
				sprite.flip_h = direction > 0


	move_and_slide()


	# ---------- DANO POR CONTATO ----------
	for i in range(get_slide_collision_count()):

		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		if body != null \
		and body.is_in_group("player") \
		and body.has_method("take_damage"):

			var dir = body.global_position - global_position

			body.take_damage(1, dir)


	handle_animation()


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
	queue_free()


func handle_animation():

	if hp <= 0:
		return

	if sprite.animation != "hit":

		if abs(velocity.x) > 0:
			sprite.play("run")
		else:
			sprite.play("idle")
