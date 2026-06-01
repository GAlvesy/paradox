extends CharacterBody2D

# ---------- CONFIG ----------
const VELOCIDADE = 60.0
const DISTANCIA_ATAQUE = 100.0
const GRAVIDADE = 900.0

var VELOCIDADE_DESVIO = 250.0
var VELOCIDADE_AVANCO = 120.0

var TEMPO_VULNERAVEL = 1.2
var COOLDOWN_DESVIO = 3.5


# ---------- VIDA ----------
var vida_maxima = 200
var vida_atual = 200


# ---------- REFERÊNCIAS ----------
@onready var anim = $AnimatedSprite2D


# ---------- ESTADOS ----------
var jogador = null

var esta_atacando = false
var esta_morto = false
var tomando_dano = false
var desviando = false
var pode_desviar = true

var fase2 = false


func _ready():

	anim.play("idle")

	add_to_group("enemy")


func _physics_process(delta):

	if !is_on_floor():
		velocity.y += GRAVIDADE * delta
	else:
		velocity.y = 0


	procurar_player()


	if esta_morto \
	or tomando_dano \
	or desviando:

		ajustar_olhar_pela_velocidade()

		move_and_slide()

		return


	if jogador and !esta_atacando:

		var direcao =  jogador.global_position.x - global_position.x

		var distancia = abs(direcao)


		if distancia <= DISTANCIA_ATAQUE:

			iniciar_ataque()

		else:

			velocity.x = sign(direcao) * VELOCIDADE

			anim.play("idle")

	else:

		if !esta_atacando:

			velocity.x = 0

			anim.play("idle")


	ajustar_olhar_pela_velocidade()

	move_and_slide()


# ---------- PLAYER MAIS PRÓXIMO ----------
func procurar_player():

	var players = get_tree().get_nodes_in_group("player")

	if players.is_empty():

		jogador = null

		return


	jogador = players[0]

	for p in players:

		if global_position.distance_to(
		p.global_position) < \
		global_position.distance_to(
		jogador.global_position):

			jogador = p


# ---------- FLIP ----------
func ajustar_olhar_pela_velocidade():

	if velocity.x > 0:

		anim.flip_h = true

	elif velocity.x < 0:

		anim.flip_h = false

	elif jogador \
	and !esta_atacando:

		var dir_jogador = jogador.global_position.x - global_position.x

		if dir_jogador > 0:
			anim.flip_h = true

		elif dir_jogador < 0:
			anim.flip_h = false


# ---------- ATAQUE ----------
func iniciar_ataque():

	esta_atacando = true

	anim.play("ataque")

	var timer = get_tree().create_timer(0.3)


	while timer.time_left > 0 \
	and !tomando_dano \
	and !esta_morto:

		if jogador:

			var dir_atual = jogador.global_position.x - global_position.x

			velocity.x = sign(dir_atual) * VELOCIDADE_AVANCO


		ajustar_olhar_pela_velocidade()

		move_and_slide()

		await get_tree().process_frame


	velocity.x = 0


	if esta_morto \
	or tomando_dano:

		return


	if jogador:

		var dist = global_position.distance_to(jogador.global_position)

		if dist <= DISTANCIA_ATAQUE + 20:

			var dir = jogador.global_position - global_position

			jogador.take_damage(
			1,
			dir)


	await anim.animation_finished


	if jogador:

		var fuga = global_position.x - jogador.global_position.x

		velocity.x = sign(fuga) * (VELOCIDADE * 1.8)


	anim.play("idle")


	var timer_recuo = get_tree().create_timer(0.4)

	while timer_recuo.time_left > 0 \
	and !esta_morto \
	and !tomando_dano:

		move_and_slide()

		await get_tree().process_frame


	velocity.x = 0

	anim.play("idle")


	var vulneravel = get_tree().create_timer( TEMPO_VULNERAVEL)

	while vulneravel.time_left > 0 \
	and !tomando_dano \
	and !esta_morto:

		await get_tree().process_frame


	esta_atacando = false


# ---------- DANO ----------
func take_damage(
damage,
knockback_direction):

	if esta_morto:
		return


	if !esta_atacando \
	and pode_desviar \
	and !desviando:

		realizar_desvio()

		return


	tomando_dano = true

	esta_atacando = false

	desviando = false


	vida_atual -= damage


	var cor_original = modulate

	modulate = Color(1,0,0)

	await get_tree()\
	.create_timer(0.08)\
	.timeout

	modulate = cor_original


	velocity.x = knockback_direction .normalized().x * 120


	# ---------- FASE 2 ----------
	if !fase2 \
	and vida_atual <= \
	vida_maxima / 2:

		fase2 = true

		VELOCIDADE_AVANCO = 180.0

		COOLDOWN_DESVIO = 2.0

		print("BOSS ENFURECEU")


	if vida_atual <= 0:

		morrer()

		return


	anim.play("dano")

	await anim.animation_finished

	tomando_dano = false


# ---------- DESVIO ----------
func realizar_desvio():

	desviando = true

	pode_desviar = false


	if jogador:

		var fuga = global_position.x - jogador.global_position.x

		velocity.x = sign(fuga) * VELOCIDADE_DESVIO


	anim.play("idle")


	var timer = get_tree().create_timer(0.25)

	while timer.time_left > 0 \
	and !tomando_dano:

		move_and_slide()

		await get_tree().process_frame


	velocity.x = 0

	desviando = false

	recarregar_desvio()


func recarregar_desvio():

	await get_tree()\
	.create_timer(
	COOLDOWN_DESVIO)\
	.timeout

	pode_desviar = true


# ---------- MORTE ----------
func morrer():

	esta_morto = true

	tomando_dano = false

	desviando = false

	velocity = Vector2.ZERO

	anim.play("morte")

	if has_node(
	"CollisionShape2D"):

		$CollisionShape2D.set_deferred("disabled",true)

	await anim.animation_finished

	queue_free()
