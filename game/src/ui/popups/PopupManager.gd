extends Node

# ✅ MUDANÇA: Agora armazena caminhos para as cenas .tscn
var popup_scenes: Dictionary = {
	"economic": "res://game/src/ui/popups/EconomicMinistryPopup.tscn"
}

var popup_layer: Control = null
var is_processing_popup: bool = false  # Flag para evitar múltiplas chamadas

func _ready() -> void:
	# Godot 4.2: não há 'current_scene_changed', então ouvimos nós sendo adicionados
	get_tree().connect("node_added", Callable(self, "_on_node_added"))
	EventBus.subscribe(EventTypes.Type.POPUP_REQUESTED, self, "_on_popup_requested")

func _on_node_added(node: Node) -> void:
	if node.name == "PopupLayer" and popup_layer == null:
		popup_layer = node as Control
		print("[PopupManager] PopupLayer detectado dinamicamente!")

func _on_popup_requested(event: GameEvent) -> void:
	print("[PopupManager] Popup solicitado: ", event.data.get("type", ""))
	
	# Previne múltiplas chamadas simultâneas
	if is_processing_popup:
		print("[PopupManager] ⚠️ Já processando um popup, ignorando...")
		return
	
	is_processing_popup = true
	
	if popup_layer == null:
		push_warning("[PopupManager] PopupLayer ainda indisponível – popup ignorado.")
		is_processing_popup = false
		return
	
	var popup_type: String = event.data.get("type", "")
	if not popup_scenes.has(popup_type):
		push_warning("[PopupManager] Tipo de popup desconhecido: " + popup_type)
		is_processing_popup = false
		return
	
	print("[PopupManager] Filhos atuais no PopupLayer: ", popup_layer.get_child_count())
	
	# Remove todos os popups existentes de forma imediata
	for child in popup_layer.get_children():
		print("[PopupManager] Removendo filho: ", child.name, " (", child.get_class(), ")")
		popup_layer.remove_child(child)
		child.queue_free()
	
	print("[PopupManager] Filhos após limpeza: ", popup_layer.get_child_count())
	
	# ✅ Carrega a cena .tscn completa
	var scene_path: String = popup_scenes[popup_type]
	print("[PopupManager] Carregando cena: ", scene_path)
	
	var popup_scene = load(scene_path)
	
	if not popup_scene:
		push_error("[PopupManager] Falha ao carregar cena: " + scene_path)
		is_processing_popup = false
		return
	
	print("[PopupManager] Cena carregada, instanciando...")
	var popup_instance: Control = popup_scene.instantiate() as Control
	
	if not popup_instance:
		push_error("[PopupManager] Falha ao instanciar popup de: " + scene_path)
		is_processing_popup = false
		return
	
	print("[PopupManager] Adicionando popup ao PopupLayer...")
	popup_layer.add_child(popup_instance)
	
	# Conecta sinal de fechamento para resetar a flag
	if popup_instance.has_signal("closed"):
		popup_instance.closed.connect(_on_popup_closed)
	
	# Executa setup se o método existir
	if popup_instance.has_method("setup"):
		print("[PopupManager] Executando setup...")
		popup_instance.setup(event.data)
	
	popup_instance.set_anchors_preset(Control.PRESET_CENTER)
	print("[PopupManager] ✅ Popup '%s' carregado com sucesso!" % popup_type)
	
	is_processing_popup = false

func _on_popup_closed() -> void:
	print("[PopupManager] Popup fechado - resetando flag")
	is_processing_popup = false
