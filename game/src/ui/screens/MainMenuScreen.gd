# MainMenuScreen.gd (Versão Final, Simples e Direta)
extends Control
# ESTE SCRIPT DEVE ESTAR ANEXADO AO NÓ RAIZ DA SUA CENA Mainmenu.tscn

# Conecte o sinal 'pressed' do seu botão "Novo Jogo" a esta função.
func _on_new_game_button_pressed():
	print("Botão 'Novo Jogo' pressionado. A chamar o GameStateMachine global...")
	
	# A MÁGICA ACONTECE AQUI:
	# Chamamos o Autoload DIRETAMENTE pelo seu nome.
	# Não há nenhuma variável 'state_machine' para ser nula.
	GameStateMachine.switch_to_scene(GameStateMachine.SCENES.DIFFICULTY_SELECT)
