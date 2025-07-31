extends Node2D

# === REFERÊNCIAS UI (ajuste apenas se nomes mudarem na cena) ===

@onready var date_label = $"HighPanel Tex/date_label"
@onready var revolution_bar = $"LeftPanel Tex/LeftPanel/RevolutionBar"
@onready var notification_label = $"NotificationTex/NotificationContainer/RichTextLabel"

@onready var play_button = $"HighPanel Tex/Play Botton"
@onready var pause_button = $"HighPanel Tex/Pause Botton"
@onready var menu_button = $"HighPanel Tex/Menu Botton"

# Corrigido: paths reais dos botões dos ministérios
@onready var min_consult_buttons = [
	$"Min 1/Min1Container/ConsultarMin1",
	$"Min 2/Min2Container/ConsultarMin2",
	$"Min 3/Min3Container/ConsultarMin3",
	$"Min 4/Min4Container/ConsultarMin4"
]

@onready var regions = {
	"Norte": $North,
	"Centro": $Midle,
	"Sul": $South
}

# Só existe lbl_dinheiro, demais HUDs são ignorados por ora
@onready var lbl_dinheiro = $"Min 1/Min1Container/lbl_dinheiro"
# Se criar mais labels na UI, só adicionar aqui e ajustar update_hud()

# === VARIÁVEIS DO JOGO ===
var current_month := 0
var current_year := 1970
var is_paused := true

var dinheiro := 300000

var months := [
	"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
	"Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
]

# === INICIALIZAÇÃO ===
func _ready():
	_update_date()
	_update_hud()

	# Botões principais
	play_button.pressed.connect(_on_play)
	pause_button.pressed.connect(_on_pause)
	menu_button.pressed.connect(_on_menu)

	# Botões dos ministérios
	for i in range(min_consult_buttons.size()):
		var button = min_consult_buttons[i]
		if button:
			button.pressed.connect(_on_ministry_clicked.bind(i + 1))
		else:
			push_warning("❗ Botão do ministério " + str(i + 1) + " não encontrado.")

	# Regiões do mapa (Polygon2D via input_event)
	for region_name in regions.keys():
		var region_node = regions[region_name]
		if region_node:
			region_node.connect("input_event", Callable(self, "_on_region_input").bind(region_name))

# --- BOTÕES PRINCIPAIS ---
func _on_play():
	is_paused = false
	advance_month()

func _on_pause():
	is_paused = true
	show_notification("⏸️ Tempo pausado.")

func _on_menu():
	show_notification("📋 Menu ainda não implementado.")

# --- BOTÕES DOS MINISTÉRIOS ---
func _on_ministry_clicked(index: int):
	show_notification("📊 Ministério " + str(index) + " consultado.")

# --- CLIQUE NAS REGIÕES DO MAPA ---
func _on_region_input(viewport, event, shape_idx, region_name):
	if event is InputEventMouseButton and event.pressed:
		_on_region_hover(region_name)

func _on_region_hover(region_name: String):
	show_notification("🗺️ Região: " + region_name)

# --- AVANÇO DE MÊS, DATA E HUD ---
func advance_month():
	if is_paused:
		return

	current_month += 1
	if current_month >= 12:
		current_month = 0
		current_year += 1

	# Atualiza só dinheiro como exemplo de HUD real
	dinheiro -= randi_range(1000, 5000)

	_update_date()
	_update_hud()
	_update_revolution()

func _update_date():
	date_label.text = months[current_month] + " de " + str(current_year)

func _update_hud():
	lbl_dinheiro.text = "Dinheiro: $%d" % dinheiro

func _update_revolution():
	var pct: float = clamp((current_year - 1970) * 3 + current_month * 0.25, 0.0, 100.0)
	revolution_bar.value = pct

# --- NOTIFICAÇÃO ---
func show_notification(msg: String):
	notification_label.text = msg
