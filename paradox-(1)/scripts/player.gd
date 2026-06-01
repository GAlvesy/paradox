extends CharacterBody2D

@export var left_action = "left"
@export var right_action = "right"
@export var jump_action = "jump"
@export var attack_action = "attack"
@export var dash_action = "dash"



const SPEED = 220.0
const ACCELERATION = 1200.0
const FRICTION = 1500.0
const JUMP_FORCE = -450.0

const COYOTE_TIME = 0.15
const JUMP_BUFFER = 0.15

const DASH_SPEED = 700.0
const DASH_TIME = 0.15
const DASH_COOLDOWN = 0.4



var shield = false
var damage_multiplier = 1.0
var speed_multiplier = 1.0

var is_dashing = false
var can_dash = true

var hp = 5
var max_hp = 5
var can_take_damage = true

var attacking = false
var hit_once = false

var coyote_timer = 0.0
var jump_buffer_timer = 0.0

var is_dead = false
var checkpoint_position = Vector2.ZERO

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea


func _ready():
	attack_area.monitoring = false
	add_to_group("player")

	checkpoint_position = global_position


func _physics_process(delta):

	if is_dead:
		return
	if global_position.y > 2000:
		die()

	handle_movement(delta)
	handle_attack()
	handle_animations()

	move_and_slide()


func handle_movement(delta):

	if Input.is_action_just_pressed(dash_action) and can_dash:
		start_dash()

	if !is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed(jump_action):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer -= delta

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_FORCE
		jump_buffer_timer = 0

	if Input.is_action_just_released(jump_action) and velocity.y < 0:
		velocity.y *= 0.5

	var direction = Input.get_axis(left_action, right_action)

	if direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * SPEED * speed_multiplier,
			ACCELERATION * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			FRICTION * delta
		)

	if is_dashing:
		return

	if direction > 0:
		sprite.flip_h = false
		attack_area.position = Vector2(28,0)

	elif direction < 0:
		sprite.flip_h = true
		attack_area.position = Vector2(-15,0)


func handle_attack():

	if Input.is_action_just_pressed(attack_action) and !attacking:
		attack()


func attack():

	attacking = true
	hit_once = false

	sprite.play("attack")
	attack_area.monitoring = true

	await get_tree().create_timer(0.2).timeout

	attack_area.monitoring = false
	attacking = false


func _on_attack_area_body_entered(body):

	if hit_once:
		return

	if !body.is_in_group("enemy"):
		return

	var direction = body.global_position - global_position

	body.take_damage(1 * damage_multiplier, direction)

	hit_once = true



func start_dash():

	can_dash = false
	is_dashing = true

	sprite.play("dash")

	var direction = 1

	if sprite.flip_h:
		direction = -1

	velocity.y = 0
	velocity.x = direction * DASH_SPEED

	await get_tree().create_timer(DASH_TIME).timeout

	is_dashing = false

	await get_tree().create_timer(DASH_COOLDOWN).timeout

	can_dash = true


func hit_stop(time := 0.05):

	get_tree().paused = true

	await get_tree().create_timer(time, true).timeout

	get_tree().paused = false


func handle_animations():

	if attacking:
		return

	if is_dashing:
		sprite.play("dash")
		return

	if !is_on_floor():

		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")

	elif abs(velocity.x) > 10:
		sprite.play("run")

	else:
		sprite.play("idle")


func take_damage(damage, knockback_direction):
	if shield or !can_take_damage or is_dead:
		return

	can_take_damage = false

	hp -= damage

	velocity.x = knockback_direction.normalized().x * 300
	velocity.y = -150

	if hp <= 0:
		die()

	else:
		await get_tree().create_timer(0.5).timeout
		can_take_damage = true


func die():


	if is_dead:
		return

	is_dead = true

	hide()
	set_physics_process(false)

	await get_tree().create_timer(2.0).timeout

	hp = 5
	can_take_damage = true

	global_position = checkpoint_position
	velocity = Vector2.ZERO

	show()
	set_physics_process(true)

	is_dead = false





# ---------- POÇÕES / POWERUPS ----------

func heal(amount):
	hp += amount
	hp = clamp(hp, 0, max_hp)

	modulate = Color(0,1,0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE


var shield_timer = null

func add_shield():

	shield = true
	modulate = Color(0.4,0.7,1)

	if shield_timer:
		shield_timer.kill()

	shield_timer = get_tree().create_timer(5.0)
	await shield_timer.timeout

	shield = false
	modulate = Color.WHITE


var damage_buff_active = false

func boost_damage():

	damage_buff_active = true
	damage_multiplier = 2.0

	modulate = Color(1, 0.3, 0.3)

	await get_tree().create_timer(5.0).timeout

	damage_buff_active = false
	damage_multiplier = 1.0

	modulate = Color.WHITE

var speed_buff_active = false

func boost_speed():

	speed_buff_active = true
	speed_multiplier = 1.5

	modulate = Color(1, 0.5, 1)

	await get_tree().create_timer(5.0).timeout

	speed_buff_active = false
	speed_multiplier = 1.0

	modulate = Color.WHITE
