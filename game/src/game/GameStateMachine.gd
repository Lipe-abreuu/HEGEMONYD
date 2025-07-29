# GameStateMachine.gd (Autoload)
extends Node

# Enum com os estados/cenas do jogo
enum SCENES {
	MAIN_MENU,
	DIFFICULTY_SELECT,
	GAME_PLAYING
}

# Dicionário com os caminhos das cenas
var scene_paths: Dictionary = {}
var current_scene_node: Node
var difficulty: String = "Reformista"  # Valor default, sobrescrito na tela de dificuldade

func _ready() -> void:
	# Inicializa os caminhos das cenas
	scene_paths = {
		SCENES.MAIN_MENU: "res://Mainmenu.tscn",
		SCENES.DIFFICULTY_SELECT: "res://game/src/ui/screens/DifficultyScreen.tscn",
		SCENES.GAME_PLAYING: "res://game/src/ui/screens/GameScreen.tscn"
	}
	print("GameStateMachine (Autoload) pronto.")

func switch_to_scene(scene_enum):
	var path = scene_paths.get(scene_enum, "")
	if path != "":
		print("MUDANÇA DE CENA PARA: " + path)
		get_tree().change_scene_to_file(path)
	else:
		push_error("FALHA AO TROCAR DE CENA: Caminho não encontrado para enum: " + str(scene_enum))
