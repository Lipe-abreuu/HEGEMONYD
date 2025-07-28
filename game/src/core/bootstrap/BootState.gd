# BootState.gd - Estado de inicialização do jogo
extends State
class_name BootState

func enter() -> void:
	# Este estado tem a responsabilidade de preparar tudo antes do menu.
	# Por exemplo:
	# - Carregar configurações do jogador.
	# - Garantir que singletons estão prontos.
	# - Preparar o sistema de save/load.
	
	print("Estado de Boot: Inicializando sistemas...")
	
	# Após a inicialização, transiciona para o menu principal.
	# Usamos 'call_deferred' para garantir que a transição ocorra no próximo frame,
	# dando tempo para que tudo na função 'enter' seja concluído sem problemas.
	state_machine.transition_to_by_name.call_deferred(GameStateMachine.GameStates.MAIN_MENU)

func exit() -> void:
	print("Estado de Boot: Concluído. Transicionando para o Menu Principal.")
