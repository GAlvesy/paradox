extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	if !body.is_in_group("player"):
		return

	aplicar_efeito(body)
	queue_free()


func aplicar_efeito(jogador):
	if jogador.has_method("boost_damage"):
		jogador.boost_damage()
