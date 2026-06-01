extends Camera2D

# --- Referências e Configurações ---
# Precisamos apontar quem são os jogadores. Você pode arrastar as instâncias no Inspector
@export var jogador_1: CharacterBody2D
@export var jogador_2: CharacterBody2D

# Configurações de Posição
@export var suavizacao_posicao: float = 5.0 # Quão rápido a câmera segue (números maiores são mais rápidos)

# Configurações de Zoom
@export var zoom_perto: Vector2 = Vector2(1.2, 1.2) # Zoom quando estão próximos (apontando para Vector2)
@export var zoom_longe: Vector2 = Vector2(0.6, 0.6) # Zoom quando estão afastados (números menores dão mais zoom out)
@export var suavizacao_zoom: float = 5.0

# Define a distância (em pixels) que fará a câmera atingir o zoom out máximo
@export var distancia_maxima_para_zoom: float = 800.0

# Variável interna para calcular o ponto médio
var ponto_medio_atual: Vector2

func _ready():
	# Uma verificação rápida para garantir que os jogadores foram definidos
	if not jogador_1 or not jogador_2:
		printerr("ERRO: Câmera2D não tem os jogadores definidos no Inspector!")

func _process(delta):
	# Se um dos jogadores não existir (ex: morreu), a câmera segue apenas o outro
	if not is_instance_valid(jogador_1):
		if is_instance_valid(jogador_2):
			global_position = global_position.lerp(jogador_2.global_position, suavizacao_posicao * delta)
		return
	
	if not is_instance_valid(jogador_2):
		global_position = global_position.lerp(jogador_1.global_position, suavizacao_posicao * delta)
		return

	# --- LÓGICA 1: POSIÇÃO (SEGUIR O CENTRO) ---
	# O ponto médio é simplesmente a soma das posições dividida por 2
	ponto_medio_atual = (jogador_1.global_position + jogador_2.global_position) / 2.0
	
	# Movemos a câmera suavemente (Interpolation - LERP) até o ponto médio
	# Isso faz a câmera nunca "saltar" instantaneamente
	global_position = global_position.lerp(ponto_medio_atual, suavizacao_posicao * delta)

	# --- LÓGICA 2: ZOOM DINÂMICO ---
	# Calcula a distância real entre eles usando a função nativa do Vector2
	var distancia_entre_eles = jogador_1.global_position.distance_to(jogador_2.global_position)
	
	# Normaliza essa distância para um valor entre 0.0 (perto) e 1.0 (longe ou mais longe)
	var proporcao = clamp(distancia_entre_eles / distancia_maxima_para_zoom, 0.0, 1.0)
	
	# Calculamos qual deve ser o zoom alvo com base na proporção calculada
	var zoom_alvo = zoom_perto.lerp(zoom_longe, proporcao)
	
	# Aplicamos o zoom calculado suavemente
	zoom = zoom.lerp(zoom_alvo, suavizacao_zoom * delta)
