# res://game/src/ui/screens/GameScreen.gd
extends Node2D

# === REFERÊNCIAS UI ===
@onready var date_label: Label = $"HighPanel Tex/date_label"
@onready var revolution_bar: ProgressBar = $"LeftPanel Tex/LeftPanel/RevolutionBar"
@onready var notification_label: RichTextLabel = $"NotificationTex/NotificationContainer/RichTextLabel"

@onready var play_button: Button = $"HighPanel Tex/Play Botton"
@onready var pause_button: Button = $"HighPanel Tex/Pause Botton"
@onready var menu_button: Button = $"HighPanel Tex/Menu Botton"

# (O resto das referências @onready permanece igual)
@onready var min_consult_buttons: Array[Button] = [
												  $"Min 1/Min1Container/ConsultarMin1" as Button,
												  $"Min 2/Min2Container/ConsultarMin2" as Button,
												  $"Min 3/Min3Container/ConsultarMin3" as Button,
												  $"Min 4/Min4Container/ConsultarMin4" as Button
												  ]
@onready var regions: Dictionary = { "Norte": $North, "Centro": $Midle, "Sul": $South }
@onready var lbl_dinheiro: Label = $"Min 1/Min1Container/lbl_dinheiro"
@onready var save_button: TextureButton = $"SaveBG/SaveContainer/SaveButton"
@onready var load_button: TextureButton = $"SaveBG/SaveContainer/LoadButton"
@onready var status_label: Label = $"SaveBG/SaveContainer/StatusLabel"
@onready var data_display: RichTextLabel = $"SaveBG/SaveContainer/DataDisplay"

# === GAMEDATA ===
var game_data: GameData

# === INICIALIZAÇÃO ===
func _ready() -> void:
	# 1. CARREGAR OU CRIAR GAMEDATA
	if SaveManager and SaveManager.get_current_game_data():
		print("GameScreen: Dados encontrados no SaveManager, carregando...")
		game_data = SaveManager.get_current_game_data()
	else:
		print("GameScreen: Nenhum dado no SaveManager, criando novo GameData...")
		game_data = GameData.new()
		game_data.initialize_default_data()

	# 2. EMITIR O EVENTO GAME_STARTED
	# O Autoload TimeSystem irá "ouvir" este evento para se configurar.
	if EventBus:
		EventBus.emit_event(EventTypes.Type.GAME_STARTED, {"game_data": game_data}, "GameScreen")

	# 3. CONFIGURAR A UI INICIAL
	_load_game_data_to_ui()
	_connect_signals()

# Conecta todos os sinais
func _connect_signals() -> void:
	# Botões principais
	play_button.pressed.connect(_on_play)
	pause_button.pressed.connect(_on_pause)
	menu_button.pressed.connect(_on_menu)

	# (O resto das conexões de sinal permanece igual)
	if save_button: save_button.pressed.connect(_on_save_pressed)
	if load_button: load_button.pressed.connect(_on_load_pressed)
	for i in min_consult_buttons.size():
		var button: Button = min_consult_buttons[i]
		if button: button.pressed.connect(_on_ministry_clicked.bind(i + 1))
	for region_name in regions.keys():
		var poly: Variant = regions[region_name]
		if poly and poly.has_signal("input_event"):
			poly.input_event.connect(_on_region_input.bind(region_name))

	# Conectar aos eventos do EventBus para atualizar a UI
	if EventBus:
		EventBus.subscribe(EventTypes.Type.DAY_PASSED, self, "_on_day_passed")
		EventBus.subscribe(EventTypes.Type.PHASE_CHANGED, self, "_on_phase_changed")
		EventBus.subscribe(EventTypes.Type.MANDATORY_EVENT, self, "_on_mandatory_event")

# --- CONTROLE DE TEMPO ---
func _on_play() -> void:
	# Agora chamamos o Autoload TimeSystem diretamente pelo seu nome global.
	TimeSystem.resume_time()
	show_notification("▶️ Tempo retomado.")

func _on_pause() -> void:
	TimeSystem.pause_time()
	show_notification("⏸️ Tempo pausado.")

func _on_menu() -> void:
	TimeSystem.pause_time()
	show_notification("Menu ainda não implementado.")

# (O resto do script GameScreen.gd permanece exatamente o mesmo)
# ... (callbacks de eventos, _update_ui, save/load, etc.) ...
# === CALLBACKS DO EVENTBUS PARA ATUALIZAR UI ===
func _on_day_passed(event):
	game_data.treasury -= randi_range(1_000, 5_000)
	_update_ui()
	show_notification("📅 " + Calendar.date_to_string(event.data.date))

func _on_phase_changed(event):
	var phase_name = Calendar.get_phase_name(event.data.new_phase)
	show_notification("🏛️ Nova fase histórica: " + phase_name)
	_update_ui()

func _on_mandatory_event(event):
	show_notification("📢 Evento histórico: " + event.data.id)
	if event.data.id == "final_coup_attempt":
		TimeSystem.pause_time()

# --- ATUALIZAÇÃO DA UI ---
func _update_ui() -> void:
	if not game_data: return
	_update_date()
	_update_hud()
	_update_revolution()
	_update_data_display()

func _update_date() -> void:
	date_label.text = Calendar.date_to_string(game_data.current_date)

func _update_hud() -> void:
	lbl_dinheiro.text = "Dinheiro: $%s" % str(game_data.treasury)

func _update_revolution() -> void:
	var current_date = game_data.current_date
	var year = current_date["year"]
	var month = current_date["month"]
	var total_days = (year - 1970) * 365 + month * 30
	var max_days = (1973 - 1970) * 365 + 9 * 30
	var pct: float = clamp((float(total_days) / float(max_days)) * 100.0, 0.0, 100.0)
	revolution_bar.value = pct

# --- NOTIFICAÇÕES ---
func show_notification(msg: String) -> void:
	notification_label.text = msg

# === SISTEMA DE SAVE/LOAD ===
func _on_save_pressed() -> void:
	var save_path = "user://test_gamedata.tres"
	var result = ResourceSaver.save(game_data, save_path)
	if result == OK:
		status_label.text = "✅ Dados salvos: " + save_path
		show_notification("💾 GameData salvo com sucesso!")
	else:
		status_label.text = "❌ Erro ao salvar: " + str(result)
		show_notification("❌ Erro ao salvar GameData!")

func _on_load_pressed() -> void:
	var save_path = "user://test_gamedata.tres"
	if not FileAccess.file_exists(save_path):
		status_label.text = "❌ Arquivo não encontrado!"
		show_notification("❌ Arquivo de save não encontrado!")
		return
	var loaded_data = ResourceLoader.load(save_path) as GameData
	if loaded_data:
		game_data = loaded_data
		if EventBus:
			EventBus.emit_event(EventTypes.Type.GAME_STARTED, {"game_data": game_data}, "GameScreen")
		_load_game_data_to_ui()
		status_label.text = "✅ Dados carregados!"
		show_notification("📁 GameData carregado com sucesso!")
	else:
		status_label.text = "❌ Erro ao carregar!"
		show_notification("❌ Erro ao carregar GameData!")

func _load_game_data_to_ui():
	if not game_data: return
	print("GameScreen: Carregando dados do save na interface...")
	_update_ui()
	print("GameScreen: Interface atualizada com dados do save!")

func _update_data_display() -> void:
	if not game_data or not data_display: return
	var display_text = "[b]=== ESTADO DO JOGO ===[/b]\n"
	display_text += "Data: %s\n" % Calendar.date_to_string(game_data.current_date)
	display_text += "Fase Histórica: %s\n" % Calendar.get_phase_name(game_data.historical_phase)
	display_text += "Tesouro: [color=green]$%s[/color]\n" % str(game_data.treasury)
	data_display.text = display_text

# --- BOTÕES DOS MINISTÉRIOS ---
func _on_ministry_clicked(index: int) -> void:
	match index:
		1: _open_economic_popup()
		2: show_notification("⚖️ Defesa ainda sem popup.")
		3: show_notification("👥 Interior ainda sem popup.")
		4: show_notification("🛠️ Planejamento ainda sem popup.")

func _open_economic_popup() -> void:
	show_notification("📊 Abrindo Ministério da Economia…")
	if EventBus:
		EventBus.emit_event(EventTypes.Type.POPUP_REQUESTED, {"type": "economic"}, "UI")

# --- REGIÕES DO MAPA ---
func _on_region_input(_viewport: Node, _event: InputEvent, _shape_idx: int, region_name: String) -> void:
	if _event is InputEventMouseButton and _event.pressed:
		show_notification("🗺️ Região: " + region_name)
