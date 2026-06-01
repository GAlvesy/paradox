extends CharacterBody2D

const SPEED = 80.0
const GRAVITY = 980.0

var hp = 3
var direction = -1

var ray_left
var ray_right

@onready var sprite = $Visual/AnimatedSprite2D


func _ready():
	add_to_group("enemy")

	ray_left = get_node("RayCastLeft")
	ray_right = get_node("RayCastRight")

	print("LEFT:", ray_left)
	print("RIGHT:", ray_right)


func _physics_process(delta):

	if ray_left == null or ray_right == null:
		return

	# gravidade
	if !is_on_floor():
		velocity.y += GRAVITY * delta

	# movimento
	velocity.x = direction * SPEED

	# virar ao chegar na borda
	if direction == -1 and !ray_left.is_colliding():
		flip()

	if direction == 1 and !ray_right.is_colliding():
		flip()

	move_and_slide()


	# dano por contato
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)

		var body = collision.get_collider()

		if body != null and body.has_method("take_damage") and body.is_in_group("player"):

			var dir = body.global_position - global_position
			body.take_damage(1, dir)

	handle_animation()


func flip():

	direction *= -1

	if direction == 1:
		sprite.flip_h = direction < 0
	else:
		sprite.flip_h = direction < 0


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

	if abs(velocity.x) > 0:
		sprite.play("run")
	else:
		sprite.play("idle")


func _on_damage_area_body_entered(body):

	print("BODY:", body.name)
	print("TIPO:", body.get_class())
	print("GROUPS:", body.get_groups())

	if body.has_method("take_damage"):

		var dir = body.global_position - global_position
		body.take_damage(1, dir)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
