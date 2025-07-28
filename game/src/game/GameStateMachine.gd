# GameStateMachine.gd (Versão Autoload Completa e Corrigida)
extends Node

# O enum com os nomes das nossas cenas
enum SCENES {
	MAIN_MENU,
	DIFFICULTY_SELECT,
	GAME_PLAYING
}

# O dicionário que mapeia os nomes aos ficheiros de cena
var scene_paths: Dictionary = {}
var current_scene_node: Node

# A função _ready é chamada automaticamente quando o jogo começa.
func _ready() -> void:
	# Preenchemos o dicionário aqui, quando é seguro fazê-lo.
	# --- CORREÇÃO CRÍTICA NOS CAMINHOS ---
	scene_paths = {
		SCENES.MAIN_MENU: "res://Mainmenu.tscn",
		SCENES.DIFFICULTY_SELECT: "res://game/src/ui/screens/DifficultyScreen.tscn",
		SCENES.GAME_PLAYING: "res://game/src/ui/screens/GameScreen.tscn"
	}
	print("GameStateMachine (Autoload) pronto.")

# A função para mudar de cena.
func switch_to_scene(scene_key: SCENES) -> void:
	# Remove a cena antiga, se existir
	if is_instance_valid(current_scene_node):
		current_scene_node.queue_free()

	# Carrega e adiciona a nova cena
	var new_scene_path = scene_paths.get(scene_key)
	if new_scene_path and FileAccess.file_exists(new_scene_path):
		var scene_resource = load(new_scene_path)
		current_scene_node = scene_resource.instantiate()
		get_tree().root.add_child(current_scene_node)
		print("MUDANÇA DE CENA PARA: " + new_scene_path)
	else:
		push_error("FALHA AO CARREGAR: O ficheiro de cena não foi encontrado em: " + str(new_scene_path))
