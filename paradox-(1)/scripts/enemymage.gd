extends CharacterBody2D

const GRAVITY = 980.0

const SHOOT_COOLDOWN = 1.2
const TELEPORT_COOLDOWN = 2.5

const FLOAT_AMPLITUDE = 15.0
const FLOAT_SPEED = 2.0
const MOVE_SPEED_X = 40.0

var player = null

var shoot_timer = 0.0
var teleport_timer = 1.5

var hp = 3

@onready var sprite = $AnimatedSprite2D

var ProjectileScene = preload("res://prefabs/Projectile.tscn")

var time = 0.0
var base_y = 0.0


func _ready():
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemy")

	base_y = global_position.y


func _physics_process(delta):

	if player == null:
		return

	time += delta

	look_at_player()

	# 💨 VOAR (substitui gravidade)
	var float_y = sin(time * FLOAT_SPEED) * FLOAT_AMPLITUDE

	# ➡️ segue player no X suavemente
	var target_x = move_toward(global_position.x, player.global_position.x, MOVE_SPEED_X * delta)

	global_position = Vector2(target_x, base_y + float_y)

	# cooldown tiro
	if shoot_timer > 0:
		shoot_timer -= delta

	if shoot_timer <= 0:
		shoot()

	# cooldown teleport
	if teleport_timer > 0:
		teleport_timer -= delta

	if teleport_timer <= 0:
		teleport()

	move_and_slide()


func look_at_player():
	sprite.flip_h = player.global_position.x > global_position.x


# 🔫 TIRO
func shoot():

	shoot_timer = SHOOT_COOLDOWN

	var proj = ProjectileScene.instantiate()
	get_tree().current_scene.add_child(proj)

	proj.global_position = global_position

	var dir = (player.global_position - global_position).normalized()
	proj.direction = dir


# 🌀 TELEPORTE
func teleport():

	teleport_timer = TELEPORT_COOLDOWN

	visible = false

	await get_tree().create_timer(0.15).timeout

	var offset = Vector2(
		randf_range(-180, 180),
		randf_range(-60, 60)
	)

	global_position = player.global_position + offset

	# atualiza base do voo pra não “quebrar altura”
	base_y = global_position.y

	await get_tree().create_timer(0.1).timeout

	visible = true


# 💥 DANO
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


func _on_damage_area_body_entered(body):

	if body.is_in_group("player"):

		var dir = body.global_position - global_position

		body.take_damage(1, dir)
