# game/src/core/persistence/SaveManager.gd
extends Node

# === SINAIS ===
signal save_completed(success: bool, file_path: String)
signal load_completed(success: bool, game_data: GameData)

# === CONFIGURAÇÕES ===
const SAVE_EXTENSION = ".tres"
const SAVE_FOLDER = "user://"
const LAST_SAVE_FILE = "user://last_save.txt"
const DEFAULT_SAVE_NAME = "gamescreen_save"

# === DADOS ATUAIS ===
var current_game_data: GameData

func _ready():
	print("SaveManager inicializado - Sistema compatível com GameScreen")

# === MÉTODOS PRINCIPAIS ===

func save_game(save_name: String = DEFAULT_SAVE_NAME) -> bool:
	print("SaveManager: Salvando jogo - ", save_name)

	if not current_game_data:
		print("SaveManager: ERRO - Nenhum GameData definido!")
		save_completed.emit(false, "")
		return false

	# Definir caminho do save
	var save_path = SAVE_FOLDER + save_name + SAVE_EXTENSION
	print("SaveManager: Caminho do save: ", save_path)

	# Atualizar timestamp do save
	current_game_data.save_date = Time.get_datetime_string_from_system()

	# Salvar usando ResourceSaver (mesmo sistema do GameScreen)
	var result = ResourceSaver.save(current_game_data, save_path)

	if result == OK:
		print("SaveManager: Save realizado com sucesso!")

		# Atualizar arquivo de último save
		_update_last_save_file(save_name)

		save_completed.emit(true, save_path)
		return true
	else:
		print("SaveManager: ERRO ao salvar - Código: ", result)
		save_completed.emit(false, save_path)
		return false

func load_game(save_name: String) -> bool:
	print("SaveManager: Carregando jogo - ", save_name)

	var save_path = SAVE_FOLDER + save_name + SAVE_EXTENSION

	if not FileAccess.file_exists(save_path):
		print("SaveManager: ERRO - Arquivo não encontrado: ", save_path)
		load_completed.emit(false, null)
		return false

	# Carregar usando ResourceLoader (mesmo sistema do GameScreen)
	var loaded_data = ResourceLoader.load(save_path) as GameData

	if loaded_data:
		print("SaveManager: GameData carregado com sucesso!")

		# REMOVIDO: validação desnecessária
		current_game_data = loaded_data

		# Atualizar arquivo de último save
		_update_last_save_file(save_name)

		load_completed.emit(true, current_game_data)
		return true
	else:
		print("SaveManager: ERRO - Não foi possível carregar o arquivo!")
		load_completed.emit(false, null)
		return false

func load_last_save() -> bool:
	print("SaveManager: Carregando último save...")

	var last_save_name = _get_last_save_name()
	if last_save_name == "":
		print("SaveManager: Nenhum último save encontrado")
		load_completed.emit(false, null)
		return false

	return load_game(last_save_name)

func create_new_game(difficulty: String = "NORMAL") -> bool:
	print("SaveManager: Criando novo jogo - Dificuldade: ", difficulty)

	# Criar novo GameData
	current_game_data = GameData.new()
	current_game_data.reset_to_new_game(difficulty)

	print("SaveManager: Novo jogo criado com sucesso!")
	return true

# === MÉTODOS DE CONSULTA ===

func get_save_list() -> Array:
	print("SaveManager: Listando saves disponíveis...")

	var saves = []
	var dir = DirAccess.open(SAVE_FOLDER)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if file_name.ends_with(SAVE_EXTENSION):
				var save_name = file_name.get_basename()
				saves.append(save_name)
				print("SaveManager: Save encontrado: ", save_name)
			file_name = dir.get_next()
	else:
		print("SaveManager: ERRO - Não foi possível abrir pasta: ", SAVE_FOLDER)

	print("SaveManager: Total de saves encontrados: ", saves.size())
	return saves

func has_save(save_name: String) -> bool:
	var save_path = SAVE_FOLDER + save_name + SAVE_EXTENSION
	return FileAccess.file_exists(save_path)

func has_last_save() -> bool:
	var last_save_name = _get_last_save_name()
	if last_save_name == "":
		return false
	return has_save(last_save_name)

# === GETTERS/SETTERS ===

func get_current_game_data() -> GameData:
	return current_game_data

func set_current_game_data(data: GameData) -> void:
	current_game_data = data
	print("SaveManager: GameData definido")

# === MÉTODOS PRIVADOS ===

func _update_last_save_file(save_name: String) -> void:
	var file = FileAccess.open(LAST_SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(save_name)
		file.close()
		print("SaveManager: Último save atualizado: ", save_name)
	else:
		print("SaveManager: ERRO - Não foi possível atualizar último save")

func _get_last_save_name() -> String:
	if not FileAccess.file_exists(LAST_SAVE_FILE):
		print("SaveManager: Arquivo de último save não existe")
		return ""

	var file = FileAccess.open(LAST_SAVE_FILE, FileAccess.READ)
	if file:
		var save_name = file.get_as_text().strip_edges()
		file.close()
		print("SaveManager: Último save encontrado: ", save_name)
		return save_name
	else:
		print("SaveManager: ERRO - Não foi possível ler último save")
		return ""

# === MÉTODOS DE DEBUG ===

func debug_save_system() -> void:
	print("=== DEBUG SAVEMANAGER ===")
	print("SAVE_FOLDER: ", SAVE_FOLDER)
	print("SAVE_EXTENSION: ", SAVE_EXTENSION)
	print("LAST_SAVE_FILE: ", LAST_SAVE_FILE)
	print("Current GameData: ", current_game_data != null)
	print("Has last save: ", has_last_save())
	print("Save list: ", get_save_list())
