extends Area2D

@export_enum("Azul", "Verde", "Vermelho", "Rosa")
var tipo_powerup = "Azul"

@onready var azul = $Azul
@onready var verde = $Verde
@onready var vermelho = $Vermelho
@onready var rosa = $Rosa


func _ready():

	body_entered.connect(_on_body_entered)
	_atualizar_visual()


# ---------- MOSTRAR SÓ 1 SPRITE ----------
func _atualizar_visual():

	azul.visible = false
	verde.visible = false
	vermelho.visible = false
	rosa.visible = false

	match tipo_powerup:

		"Azul":
			azul.visible = true

		"Verde":
			verde.visible = true

		"Vermelho":
			vermelho.visible = true

		"Rosa":
			rosa.visible = true


# ---------- COLISÃO ----------
func _on_body_entered(body):

	if !body.is_in_group("player"):
		return

	aplicar_efeito(body)
	queue_free()


# ---------- EFEITOS ----------
func aplicar_efeito(jogador):

	print("Poção:", tipo_powerup)

	match tipo_powerup:

		"Azul":
			if jogador.has_method("add_shield"):
				jogador.add_shield()

		"Verde":
			if jogador.has_method("heal"):
				jogador.heal(2)

		"Vermelho":
			if jogador.has_method("boost_damage"):
				jogador.boost_damage()

		"Rosa":
			if jogador.has_method("boost_speed"):
				jogador.boost_speed()
