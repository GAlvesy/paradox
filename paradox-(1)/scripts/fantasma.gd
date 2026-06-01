extends CharacterBody2D

const VELOCIDADE_PATRULHA = 50.0
const VELOCIDADE_PERSEGUICAO = 80.0
const KNOCKBACK_FORCE = 250.0
const KNOCKBACK_TIME = 0.25

var direcao = 1
var hp = 2

var esta_perseguindo = false
var jogador = null
var pode_dar_dano = true
var knockback_timer = 0.0

@onready var anim = $AnimatedSprite2D
@onready var timer = $TimerPatrulha
@onready var area_dano = $AttackArea


func _ready():

	add_to_group("enemy")

	timer.wait_time = 3.0
	timer.timeout.connect(_virar)
	timer.start()

	# garante signal ligada
	if !area_dano.body_entered.is_connected(_on_area_dano_body_entered):
		area_dano.body_entered.connect(_on_area_dano_body_entered)


func _physics_process(delta):

	# ---------- KNOCKBACK ----------
	if knockback_timer > 0:

		knockback_timer -= delta

	else:

		# ---------- IA ----------
		if esta_perseguindo and jogador != null:

			var dir_player = jogador.global_position.x - global_position.x

			velocity.x = sign(dir_player) * VELOCIDADE_PERSEGUICAO

		else:

			velocity.x = direcao * VELOCIDADE_PATRULHA


	# ---------- FLIP ----------
	anim.flip_h = velocity.x > 0


	# ---------- ANIMAÇÕES ----------
	if abs(velocity.x) > 0:
		anim.play("fantasma_andar")
	else:
		anim.play("fantasma_idle")


	move_and_slide()


func _virar():

	if !esta_perseguindo:
		direcao *= -1


# ---------- VISÃO ----------
func _on_area_visao_body_entered(body):

	if body.is_in_group("player"):

		esta_perseguindo = true
		jogador = body


func _on_area_visao_body_exited(body):

	if body == jogador:

		esta_perseguindo = false
		jogador = null


# ---------- RECEBER DANO ----------
func take_damage(damage, knockback_direction):

	hp -= damage

	print("Fantasma tomou dano. HP:", hp)

	velocity.x = knockback_direction.normalized().x * KNOCKBACK_FORCE

	velocity.y = -100

	knockback_timer = KNOCKBACK_TIME

	if hp <= 0:
		queue_free()


# ---------- DANO AO PLAYER ----------
func _on_area_dano_body_entered(body):

	print("ENCOSTOU EM:", body.name)

	if !pode_dar_dano:
		return

	if body.is_in_group("player"):

		print("DANO NO PLAYER")

		var dir = body.global_position - global_position

		body.take_damage(1, dir)

		pode_dar_dano = false

		await get_tree().create_timer(1.0).timeout

		pode_dar_dano = true
