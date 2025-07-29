extends Node2D

# === REFERÊNCIAS DE UI ===

@onready var date_label = $"HighPanel Tex/date_label"
@onready var revolution_bar = $"LeftPanel Tex/LeftPanel/RevolutionBar"
@onready var notification_label = $"NotificationTex/NotificationContainer/RichTextLabel"

@onready var play_button = $"HighPanel Tex/Play Botton"
@onready var pause_button = $"HighPanel Tex/Pause Botton"
@onready var menu_button = $"HighPanel Tex/Menu Botton"

# Botões dos ministérios (baseado na sua estrutura real: Min1Container etc)
@onready var min_consult_buttons = [
	$Min1Container/ConsultarMin1,
	$Min2Container/ConsultarMin2,
	$Min3Container/ConsultarMin3,
	$Min4Container/ConsultarMin4
]

# Regiões do mapa (Polygon2D com colisão e input_event)
@onready var regions = {
	"Norte": $North,
	"Centro": $Midle,  # Nome real do node
	"Sul": $South
}

# === ESTADO DE JOGO ===
var current_month := 0
var current_year := 1970
var is_paused := true

var months := [
	"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
	"Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
]

# === INICIALIZAÇÃO ===
func _ready():
	_update_date()

	# Conecta botões principais
	play_button.pressed.connect(_on_play)
	pause_button.pressed.connect(_on_pause)
	menu_button.pressed.connect(_on_menu)

	# Conecta botões dos ministérios
	for i in range(min_consult_buttons.size()):
		var button = min_consult_buttons[i]
		if button:
			button.pressed.connect(_on_ministry_clicked.bind(i + 1))
		else:
			push_warning("❗ Botão do ministério " + str(i + 1) + " não encontrado.")

	# Conecta input nas regiões (Polygon2D via input_event)
	for region_name in regions.keys():
		var region_node = regions[region_name]
		if region_node:
			region_node.connect("input_event", Callable(self, "_on_region_input").bind(region_name))

# === AÇÕES DOS BOTÕES ===
func _on_play():
	is_paused = false
	advance_month()

func _on_pause():
	is_paused = true
	show_notification("⏸️ Tempo pausado.")

func _on_menu():
	show_notification("📋 Menu ainda não implementado.")

func _on_ministry_clicked(index: int):
	show_notification("📊 Ministério " + str(index) + " consultado.")

# === EVENTO DE CLIQUE NAS REGIÕES (input_event em Polygon2D) ===
func _on_region_input(viewport, event, shape_idx, region_name):
	if event is InputEventMouseButton and event.pressed:
		_on_region_hover(region_name)

func _on_region_hover(region_name: String):
	show_notification("🗺️ Região: " + region_name)

# === CONTROLE DE TEMPO ===
func advance_month():
	if is_paused:
		return

	current_month += 1
	if current_month >= 12:
		current_month = 0
		current_year += 1

	_update_date()
	_update_revolution()

func _update_date():
	date_label.text = months[current_month] + " de " + str(current_year)

func _update_revolution():
	var pct: float = clamp((current_year - 1970) * 3 + current_month * 0.25, 0.0, 100.0)
	revolution_bar.value = pct

# === NOTIFICAÇÃO ===
func show_notification(msg: String):
	notification_label.text = msg
