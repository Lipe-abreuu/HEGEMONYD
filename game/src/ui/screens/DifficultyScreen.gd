# DifficultyScreen.gd - O CÉREBRO por trás da tela de seleção de dificuldade.
extends State
class_name DifficultySelectState

# Assumindo que a sua cena de dificuldade se chama DifficultyScreen.tscn
# Se tiver outro nome, por favor, mude o caminho abaixo.
const UI_SCENE_PATH = "res://src/ui/screens/DifficultyScreen.tscn"

func enter() -> void:
	print("ESTADO: Entrou na Seleção de Dificuldade.")
	# Pede ao SceneManager para carregar a nossa UI de dificuldade.
	SceneManager.switch_to_scene(UI_SCENE_PATH)

func exit() -> void:
	print("ESTADO: Saiu da Seleção de Dificuldade.")

# Os botões na sua DifficultyScreen.tscn devem conectar-se a esta função.
func _on_difficulty_button_pressed(difficulty_name: String):
	print("Dificuldade '" + difficulty_name + "' foi selecionada.")
	# Esta chamada AGORA VAI FUNCIONAR porque a state_machine é válida.
	state_machine.transition_to_by_name(GameStateMachine.GameStates.GAME_LOADING)
