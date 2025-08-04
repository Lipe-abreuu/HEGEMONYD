# TestGameData.gd - Script para testar o sistema GameData
extends Control

@onready var save_button: Button = $VBoxContainer/SaveButton
@onready var load_button: Button = $VBoxContainer/LoadButton
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var data_display: TextEdit = $VBoxContainer/DataDisplay

var current_game_data: GameData

func _ready():
	# Conectar sinais dos botões
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)

	# Criar dados iniciais
	current_game_data = GameData.new()
	current_game_data.initialize_default_data()

	# Exibir dados iniciais
	_update_display()
	status_label.text = "GameData inicializado com dados padrão"

func _on_save_pressed():
	var save_path = "user://test_gamedata.tres"
	var result = ResourceSaver.save(current_game_data, save_path)

	if result == OK:
		status_label.text = "✅ Dados salvos com sucesso em: " + save_path
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "❌ Erro ao salvar: " + str(result)
		status_label.modulate = Color.RED

func _on_load_pressed():
	var save_path = "user://test_gamedata.tres"

	if not FileAccess.file_exists(save_path):
		status_label.text = "❌ Arquivo de save não encontrado!"
		status_label.modulate = Color.RED
		return

	var loaded_data = ResourceLoader.load(save_path) as GameData

	if loaded_data:
		current_game_data = loaded_data
		_update_display()
		status_label.text = "✅ Dados carregados com sucesso!"
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "❌ Erro ao carregar dados!"
		status_label.modulate = Color.RED

func _update_display():
	if not current_game_data:
		return

	var display_text = ""
	display_text += "=== ESTADO DO JOGO ===\n"
	display_text += "Data: %d/%d/%d\n" % [current_game_data.current_date.day, current_game_data.current_date.month, current_game_data.current_date.year]
	display_text += "Fase Histórica: %d\n" % current_game_data.historical_phase
	display_text += "Tesouro: $%s\n" % str(current_game_data.treasury)
	display_text += "\n=== MINISTÉRIOS ===\n"

	for ministry_id in current_game_data.ministries:
		var ministry = current_game_data.ministries[ministry_id]
		display_text += "%s: %d CP (Geração: %d/dia)\n" % [ministry_id.capitalize(), ministry.political_capital, ministry.daily_generation]

	display_text += "\n=== GRUPOS POPULACIONAIS ===\n"
	for pop_id in current_game_data.pops:
		var pop = current_game_data.pops[pop_id]
		display_text += "%s: %d%% apoio, %d%% influência\n" % [pop_id.capitalize(), pop.support, pop.influence]

	display_text += "\n=== REGIÕES ===\n"
	for region_id in current_game_data.regions:
		var region = current_game_data.regions[region_id]
		display_text += "%s: Infra %d, Controle: %s\n" % [region.name, region.infrastructure, region.political_control]

	display_text += "\n=== RESUMO ===\n"
	var summary = current_game_data.get_state_summary()
	for key in summary:
		display_text += "%s: %s\n" % [key, str(summary[key])]

	data_display.text = display_text
