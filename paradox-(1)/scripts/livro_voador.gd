extends CharacterBody2D

const VELOCIDADE_PATRULHA = 40.0
const VELOCIDADE_PERSEGUICAO = 120.0
const DISTANCIA_EMBOSCADA = 160.0

var hp = 2

@onready var anim = $AnimatedSprite2D

enum Estados {
	EMBOSCADA,
	CARREGANDO_BOTE,
	ROCKET_BOTE,
	PERSEGUINDO,
	RETORNANDO,
	MORTO
}

var estado_atual = Estados.EMBOSCADA

var jogador = null
var posicao_inicial = Vector2.ZERO
var tempo_perseguindo = 0.0
var pode_dar_bote = true


func _ready():

	add_to_group("enemy")

	anim.play("voar")

	posicao_inicial = global_position


func _physics_process(delta):

	if estado_atual == Estados.MORTO:
		return

	procurar_player()

	if jogador == null:
		return

	if !roles_bote() and velocity.x != 0:
		anim.flip_h = velocity.x > 0


	match estado_atual:

		Estados.EMBOSCADA:

			var alvo_flutuar = posicao_inicial + Vector2(
				0,
				sin(Time.get_ticks_msec() * 0.005) * 10
			)

			velocity = (alvo_flutuar - global_position) * 2.0

			anim.play("voar")

			if pode_dar_bote \
			and global_position.distance_to(
			jogador.global_position
			) <= DISTANCIA_EMBOSCADA:

				preparar_bote()


		Estados.CARREGANDO_BOTE, Estados.ROCKET_BOTE:

			velocity = Vector2.ZERO


		Estados.PERSEGUINDO:

			tempo_perseguindo += delta

			if tempo_perseguindo >= 5.0:

				estado_atual = Estados.RETORNANDO

			else:

				var direcao = (
					jogador.global_position -
					global_position
				).normalized()

				velocity = direcao * VELOCIDADE_PERSEGUICAO

				anim.play("voar")

				if pode_dar_bote \
				and global_position.distance_to(
				jogador.global_position
				) <= DISTANCIA_EMBOSCADA:

					preparar_bote()


		Estados.RETORNANDO:

			var dir_retorno = (
				posicao_inicial -
				global_position
			).normalized()

			velocity = dir_retorno *VELOCIDADE_PATRULHA

			anim.play("voar")

			if global_position.distance_to(
			posicao_inicial) <= 10:

				global_position = posicao_inicial

				estado_atual = Estados.EMBOSCADA


	move_and_slide()


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


func roles_bote():

	return estado_atual == Estados.CARREGANDO_BOTE \
	or estado_atual == Estados.ROCKET_BOTE


func preparar_bote():

	if estado_atual == Estados.MORTO:
		return

	estado_atual = Estados.CARREGANDO_BOTE

	pode_dar_bote = false

	anim.flip_h = (jogador.global_position.x -
	global_position.x) > 0

	anim.play("ataque")

	var alvo = jogador.global_position

	var direcao_recuo = (global_position - alvo).normalized()

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		global_position +
		(direcao_recuo * 25),
		0.2
	)

	tween.tween_callback(
		func():
		estado_atual = Estados.ROCKET_BOTE
	)

	tween.tween_property(
		self,
		"global_position",
		alvo,
		0.35
	)

	tween.tween_callback(
		func():
		dar_dano()
		encerrar_bote()
	)


func dar_dano():

	if jogador == null:
		return

	if global_position.distance_to(
	jogador.global_position) <= 50:

		var dir = jogador.global_position - global_position

		jogador.take_damage(
			1,
			dir
		)


func encerrar_bote():

	if estado_atual == Estados.MORTO:
		return

	velocity = Vector2.ZERO

	anim.play("voar")

	tempo_perseguindo = 0.0

	estado_atual = Estados.PERSEGUINDO

	recarregar_bote()


func recarregar_bote():

	await get_tree()\
	.create_timer(3.0)\
	.timeout

	pode_dar_bote = true


func take_damage(
damage,
_knockback_direction):

	if estado_atual == Estados.MORTO:
		return

	hp -= damage

	modulate = Color(1,0,0)

	await get_tree()\
	.create_timer(0.1)\
	.timeout

	modulate = Color(1,1,1)

	if estado_atual == Estados.EMBOSCADA or estado_atual == Estados.RETORNANDO:

		tempo_perseguindo = 0.0

		estado_atual = 	Estados.PERSEGUINDO

	if hp <= 0:
		morrer()


func morrer():

	estado_atual = Estados.MORTO

	velocity = Vector2.ZERO

	anim.play("morte")

	if has_node(
	"CollisionShape2D"):

		$CollisionShape2D.set_deferred(
			"disabled",
			true
		)

	await anim.animation_finished

	queue_free()
