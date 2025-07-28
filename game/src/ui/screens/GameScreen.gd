# GameScreen.gd - Controla a lógica e a UI da tela principal do jogo.
extends State
class_name GamePlayingState

# Referências para os nós principais da sua cena de jogo (.tscn)
# @onready var map_container = $MapContainer
# @onready var ministry_grid = $SidePanel/MinistryGrid
# @onready var notification_panel = $SidePanel/NotificationPanel

func enter() -> void:
	print("Estado de Jogo Principal: Entrando.")
	
	# Esta é a lógica principal para iniciar o jogo:
	# 1. Carregar e exibir a sua cena principal (.tscn).
	# 2. Conectar os sinais da UI (cliques no mapa, nos ministérios) a funções aqui.
	# 3. Iniciar o sistema de tempo (TimeSystem) para que os dias comecem a passar.
	# 4. Enviar o evento de que o jogo começou para que outros sistemas reajam.
	EventBus.emit_event(EventBus.EventType.GAME_STARTED, {}, "GamePlayingState")
	
	print("Jogo iniciado. A tela principal seria exibida agora.")

func exit() -> void:
	print("Estado de Jogo Principal: Saindo (ex: para menu de pausa ou fim de jogo).")
	# Pausar o sistema de tempo e esconder a UI principal.
	pass

# Chamado a cada frame. Usado para atualizar a UI em tempo real.
func process_update(delta: float) -> void:
	# Exemplo:
	# - Atualizar o display de data/hora.
	# - Atualizar a barra de progresso da "Revolução".
	pass

# --- Funções de Exemplo para a UI ---

func _on_region_clicked(region_name: String) -> void:
	print("Região '" + region_name + "' foi clicada.")
	# Emite um evento para que o sistema de UI saiba que precisa abrir um popup de região.
	EventBus.emit_event(EventBus.EventType.REGION_CLICKED, {"region_name": region_name}, "GamePlayingState")

func _on_ministry_clicked(ministry_name: String) -> void:
	print("Ministério '" + ministry_name + "' foi clicado.")
	# Emite um evento para abrir o popup daquele ministério.
	EventBus.emit_event(EventBus.EventType.MINISTRY_CLICKED, {"ministry_name": ministry_name}, "GamePlayingState")
