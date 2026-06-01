extends Control

# Altere para o caminho exato da sua fase se o nome for diferente
@export_file("*.tscn") var primeira_fase: String = "res://scenes/fase-1.tscn"

func _ready() -> void:
	# Conecta os cliques dos botões às funções abaixo
	$VBoxContainer/BotaoJogar.pressed.connect(_on_jogar_pressed)
	$VBoxContainer/BotaoSair.pressed.connect(_on_sair_pressed)

func _on_jogar_pressed() -> void:
	# Carrega a sua primeira fase
	get_tree().change_scene_to_file(primeira_fase)

func _on_sair_pressed() -> void:
	# Fecha o jogo
	get_tree().quit()
