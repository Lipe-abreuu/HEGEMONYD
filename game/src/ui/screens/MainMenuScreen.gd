# MainMenuScreen.gd (Versão Final e Limpa)
extends Control
# ESTE SCRIPT DEVE ESTAR ANEXADO AO NÓ RAIZ DA SUA CENA Mainmenu.tscn

# Conecte o sinal 'pressed' do seu botão "Novo Jogo" a esta função.
func _on_new_game_button_pressed():
	print("Botão 'Novo Jogo' pressionado. A chamar o GameStateMachine global...")
	
	# Chama o Autoload DIRETAMENTE pelo seu nome.
	GameStateMachine.switch_to_scene(GameStateMachine.SCENES.DIFFICULTY_SELECT)

# Conecte o sinal 'pressed' do seu botão "Sair" a esta função.
func _on_quit_button_pressed():
	get_tree().quit()
