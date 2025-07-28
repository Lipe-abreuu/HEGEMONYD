# MainMenuScreen.gd - A lógica do estado do menu
extends State
class_name MainMenuState

func enter() -> void:
	print("[ESTADO] Menu Principal entrou. A procurar botões na UI...")
	# A GameStateMachine já carregou a UI. Vamos encontrá-la.
	var ui_scene = state_machine.current_ui_scene
	if ui_scene:
		var new_game_button = ui_scene.get_node_or_null("PanelContainer/VBoxContainer/NewGameButton")
		if new_game_button:
			# Conecta o sinal do botão à função DESTE SCRIPT
			if not new_game_button.is_connected("pressed", _on_new_game_button_pressed):
				new_game_button.pressed.connect(_on_new_game_button_pressed)
			print("[ESTADO] Botão 'Novo Jogo' conectado com sucesso.")
		else:
			print("[ERRO] Não encontrou o botão 'NewGameButton' na cena!")

func exit() -> void:
	print("[ESTADO] Menu Principal saiu.")

# Esta função agora será chamada pela instância correta, que conhece a state_machine
func _on_new_game_button_pressed():
	print("[AÇÃO] Clique no 'Novo Jogo' registado!")
	state_machine.transition_to_by_name(GameStateMachine.GameStates.DIFFICULTY_SELECT)
