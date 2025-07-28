# GameStateMachine.gd - O ÚNICO GESTOR de estados e UI (VERSÃO FINAL CORRIGIDA)
extends StateMachine
class_name GameStateMachine

# O enum é declarado aqui.
enum GameStates {
	BOOT,
	MAIN_MENU,
	DIFFICULTY_SELECT,
	GAME_LOADING,
	GAME_PLAYING,
	GAME_PAUSED,
	CRISIS_MODE,
	END_GAME
}

var current_ui_scene: Control
# O dicionário é declarado aqui, mas INICIALIZADO na função _ready.
var state_to_scene_map: Dictionary

func _ready() -> void:
	# --- CORREÇÃO AQUI ---
	# Inicializamos o dicionário aqui, quando GameStates já é conhecido.
	state_to_scene_map = {
		GameStates.MAIN_MENU: "res://Mainmenu.tscn",
		GameStates.DIFFICULTY_SELECT: "res://src/ui/screens/DifficultyScreen.tscn",
		GameStates.GAME_PLAYING: "res://src/ui/screens/GameScreen.tscn"
	}
	# --- FIM DA CORREÇÃO ---

	# Regista todos os scripts de estado (a lógica)
	add_state_by_name(GameStates.MAIN_MENU, "MainMenuScreen", "res://src/ui/screens/")
	add_state_by_name(GameStates.DIFFICULTY_SELECT, "DifficultyScreen", "res://src/ui/screens/")
	add_state_by_name(GameStates.GAME_LOADING, "GameLoadingState", "res://src/game/states/")
	add_state_by_name(GameStates.GAME_PLAYING, "GameScreen", "res://src/ui/screens/")

	set_initial_state_by_name(GameStates.MAIN_MENU)
	super._ready()

func transition_to(new_state: State) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.state_machine = self

	var scene_path = state_to_scene_map.get(new_state.name)
	if scene_path:
		switch_to_ui_scene(scene_path)
	
	current_state.enter()
	state_changed.emit(current_state.name)

func switch_to_ui_scene(scene_path: String):
	if is_instance_valid(current_ui_scene):
		current_ui_scene.queue_free()

	var scene_resource = load(scene_path)
	if scene_resource:
		current_ui_scene = scene_resource.instantiate()
		get_tree().root.add_child(current_ui_scene)
	else:
		push_error("Não foi possível carregar a cena: " + scene_path)

func add_state_by_name(state_enum, script_name, script_path):
	var full_path = script_path + script_name + ".gd"
	var state_script = load(full_path)
	if state_script:
		var state_instance = state_script.new()
		state_instance.name = state_enum
		add_state(state_instance)

func set_initial_state_by_name(state_enum):
	if states.has(state_enum):
		initial_state = states[state_enum]
