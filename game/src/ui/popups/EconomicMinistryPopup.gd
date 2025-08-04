extends PopupBase
class_name EconomicMinistryPopup

# Caminhos corretos para sua estrutura
@onready var treasury_label  : Label         = $TextureRect/VBoxContainer/Tesouro
@onready var balance_label   : Label         = $TextureRect/VBoxContainer/Saldo
@onready var inflation_label : Label         = $TextureRect/VBoxContainer/Inflacao
@onready var revenue_box     : VBoxContainer = $TextureRect/VBoxContainer/ReceitasBox
@onready var close_button    : Button        = $TextureRect/VBoxContainer/Fechar

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	else:
		push_error("❌ Botão 'Fechar' não encontrado.")

func setup(data: Dictionary, priority: int = 1) -> void:
	treasury_label.text = "Tesouro: $" + str(data.get("treasury", 0))
	balance_label.text = "Saldo Mensal: $" + str(data.get("monthly_balance", 0))
	inflation_label.text = "Inflação: " + str(round(data.get("inflation_rate", 0.0) * 100)) + "%"
	
	# Limpa receitas antigas
	for c in revenue_box.get_children():
		c.queue_free()
	
	var revenues: Dictionary = data.get("revenues", {})
	for sector in revenues.keys():
		var lbl := Label.new()
		lbl.text = "- %s: $%d" % [sector.capitalize(), revenues[sector]]
		revenue_box.add_child(lbl)

func _on_close_pressed() -> void:
	print("[EconomicMinistryPopup] Fechando popup...")
	closed.emit()
	
	# Remove da árvore imediatamente em vez de queue_free()
	if get_parent():
		get_parent().remove_child(self)
	
	queue_free()
	print("[EconomicMinistryPopup] Popup removido da árvore")
