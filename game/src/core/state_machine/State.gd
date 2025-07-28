# State.gd - Classe base para todos os estados da FSM
extends Node
class_name State

# Referência à máquina de estados para solicitar transições
var state_machine: StateMachine

# Chamado quando a máquina de estados entra neste estado
func enter() -> void:
	pass

# Chamado quando a máquina de estados sai deste estado
func exit() -> void:
	pass

# Chamado a cada frame do jogo (equivalente ao _process)
func process_update(delta: float) -> void:
	pass

# Chamado a cada frame de física (equivalente ao _physics_process)
func physics_update(delta: float) -> void:
	pass

# Chamado para tratar inputs não manipulados
func unhandled_input(event: InputEvent) -> void:
	pass
