# game/src/ui/screens/MainMenuScreen.gd
extends Control

func _ready() -> void:
	print("=== DEBUG MainMenuScreen ===")
	print("SaveManager existe: ", SaveManager != null)
	
	# Conecta sinais do SaveManager
	if SaveManager:
		SaveManager.load_completed.connect(_on_load_completed)
		print("Sinais conectados")
	else:
		print("ERRO: SaveManager não encontrado!")
	
	# DEBUG: Verificar métodos do SaveManager
	_debug_save_manager()
	
	# Verifica se existe último save para habilitar botão
	_update_load_button_state()

# NOVA FUNÇÃO: Debug do SaveManager
func _debug_save_manager():
	print("=== DEBUG SAVE MANAGER ===")
	if SaveManager:
		print("Métodos disponíveis:")
		var methods = ["save_game", "load_game", "load_last_save", "create_new_game", "get_save_list", "has_save"]
		for method in methods:
			print("  - ", method, ": ", SaveManager.has_method(method))
		
		if SaveManager.has_method("get_save_list"):
			var saves = SaveManager.get_save_list()
			print("get_save_list() retornou: ", saves)
			print("Número de saves: ", saves.size())

func _on_new_game_button_pressed():
	print("=== Botão Novo Jogo pressionado ===")
	get_tree().change_scene_to_file("res://game/src/ui/screens/DifficultyScreen.tscn")

func _on_options_button_pressed():
	print("Abrindo opções...")
	_show_info_dialog("Menu de opções")

func _on_quit_button_pressed():
	print("Saindo do jogo...")
	get_tree().quit()

# Callback quando load é completado
func _on_load_completed(success: bool, game_data: GameData):
	print("=== Load completed callback ===")
	print("Success: ", success)
	print("GameData: ", game_data)
	
	if success:
		print("Save carregado com sucesso!")
		get_tree().change_scene_to_file("res://game/src/ui/screens/GameScreen.tscn")
	else:
		_show_error_dialog("Erro ao carregar o save!")

# Atualiza estado do botão de load
# Atualiza estado do botão de load
func _update_load_button_state():
	var load_button = $TextureRect2/MenuButtonsContainer/LoadGameButton

	print("=== Update Load Button ===")
	print("Load button encontrado: ", load_button != null)

	if load_button and SaveManager:
		# MUDANÇA: Verificar se há qualquer save disponível
		var saves_list = SaveManager.get_save_list()
		var has_any_save = saves_list.size() > 0

		print("Saves disponíveis: ", saves_list)
		print("Tem algum save: ", has_any_save)

		load_button.disabled = not has_any_save
		print("Botão load disabled: ", load_button.disabled)

func _on_load_game_button_pressed():
	print("=== Botão Load Game pressionado ===")

	if SaveManager:
		var saves_list = SaveManager.get_save_list()
		if saves_list.size() > 0:
			# Carregar o primeiro save disponível
			var save_name = saves_list[0]
			print("Carregando save: ", save_name)
			var result = SaveManager.load_game(save_name)
			print("Resultado do load: ", result)
		else:
			_show_error_dialog("Nenhum save encontrado!")
	else:
		_show_error_dialog("Sistema de save não disponível!")

# Função auxiliar para mostrar erros
func _show_error_dialog(message: String) -> void:
	print("Mostrando erro: ", message)
	var dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.dialog_text = message
	dialog.title = "Erro"
	dialog.popup_centered()
	dialog.confirmed.connect(func(): dialog.queue_free())

# Função auxiliar para mostrar informações
func _show_info_dialog(message: String) -> void:
	print("Mostrando info: ", message)
	var dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.dialog_text = message
	dialog.title = "Informação"
	dialog.popup_centered()
	dialog.confirmed.connect(func(): dialog.queue_free())

# Função para criar save de teste (pressione F5)
func _input(event):
	if event.is_action_pressed("ui_accept") and Input.is_key_pressed(KEY_F5):
		print("Criando save de teste...")
		var test_data = SaveManager.create_new_game("NORMAL")
		SaveManager.save_game("teste")
		_update_load_button_state()
