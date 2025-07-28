# GameLoadingState.gd - Responsável por carregar todos os assets e dados do jogo.
extends State
class_name GameLoadingState

func enter() -> void:
	print("ESTADO: A carregar o jogo...")

	# A lógica para carregar a cena de loading e inicializar os sistemas viria aqui.
	# Ex:
	# PoliticalSystem._initialize_coalition()
	# EconomicSystem._initialize_economy()
	# print("Sistemas inicializados.")

	# Após o carregamento, transiciona para o jogo principal.
	state_machine.transition_to_by_name(GameStateMachine.GameStates.GAME_PLAYING)

func exit() -> void:
	print("ESTADO: Carregamento concluído.")
