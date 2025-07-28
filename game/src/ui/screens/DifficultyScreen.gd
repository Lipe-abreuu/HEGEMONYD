# DifficultyScreen.gd - O controlador da tela de seleção de dificuldade.
extends Control

# Esta função será conectada ao botão "Reformista"
func _on_reformista_button_pressed():
	print("CLICOU na dificuldade: Reformista")
	
	# Em todos os casos, chamamos o GameStateMachine para mudar para a tela de jogo.
	GameStateMachine.switch_to_scene(GameStateMachine.SCENES.GAME_PLAYING)


# Esta função será conectada ao botão "Histórica"
func _on_historico_button_pressed():
	print("CLICOU na dificuldade: Histórica")
	GameStateMachine.switch_to_scene(GameStateMachine.SCENES.GAME_PLAYING)


# Esta função será conectada ao botão "Revolucionária"
func _on_revolucionario_button_pressed():
	print("CLICOU na dificuldade: Revolucionária")
	GameStateMachine.switch_to_scene(GameStateMachine.SCENES.GAME_PLAYING)
