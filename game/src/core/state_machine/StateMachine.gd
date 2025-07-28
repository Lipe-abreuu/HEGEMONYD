# StateMachine.gd - FSM genérica e reutilizável
extends Node
class_name StateMachine

# Sinal emitido quando um estado é alterado
signal state_changed(new_state_name)

# Dicionário para armazenar os estados
var states: Dictionary = {}
var current_state: State = null
var initial_state: State = null

func _ready() -> void:
	# Aguarda um frame para garantir que todos os nós filhos (estados) foram adicionados
	await get_tree().process_frame

	# Se houver estados como nós filhos, inicializa a partir deles
	if get_child_count() > 0:
		for child_state in get_children():
			if child_state is State:
				# Adiciona o estado e define como estado inicial se for o primeiro
				add_state(child_state)
				if not initial_state:
					set_initial_state(child_state)

	# Inicia a máquina de estados
	if initial_state:
		transition_to(initial_state)

func _process(delta: float) -> void:
	if current_state:
		current_state.process_update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.unhandled_input(event)

# Adiciona um estado à máquina
func add_state(state: State) -> void:
	state.name = state.name.to_lower() # Garante consistência
	states[state.name] = state
	state.state_machine = self

# Define o estado inicial
func set_initial_state(state: State) -> void:
	initial_state = state

# Faz a transição para um novo estado
func transition_to(new_state: State) -> void:
	if not new_state or not states.has(new_state.name):
		push_warning("Tentativa de transição para um estado nulo ou não registrado.")
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
	state_changed.emit(current_state.name)
