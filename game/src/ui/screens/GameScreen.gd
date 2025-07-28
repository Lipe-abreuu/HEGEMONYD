# GameScreen.gd - O controlador da tela principal do jogo.
extends Control

# --- Variáveis para ligar aos nós da UI ---
# Certifique-se de que os nós com estes nomes existem na sua cena GameScreen.tscn
# e que os caminhos aqui estão corretos.
@onready var date_label: Label = $TopBar/DateLabel
@onready var capital_politico_label: Label = $MinistriesContainer/MinistryCard1/HBoxContainer/ValueLabel # Exemplo de caminho

# A função _ready é chamada uma vez quando a cena está pronta.
func _ready() -> void:
	print("A tela principal do jogo (GameScreen) está pronta.")
	# Começamos a contar o tempo assim que a tela do jogo aparece.
	if Engine.has_singleton("TimeSystem"):
		TimeSystem.start_time()

# A função _process é chamada a cada frame, ideal para atualizar a UI.
func _process(delta: float) -> void:
	# --- ATUALIZAR A DATA ---
	# A cada frame, pedimos a data ao TimeSystem e atualizamos o texto do Label.
	if Engine.has_singleton("TimeSystem"):
		var current_date = TimeSystem.current_date
		if current_date:
			# Formato de exemplo, ajuste como preferir.
			date_label.text = "%s %d, %d" % [get_month_name(current_date.month), current_date.day, current_date.year]

	# --- ATUALIZAR O CAPITAL POLÍTICO ---
	if Engine.has_singleton("PoliticalSystem"):
		var capital = PoliticalSystem.political_capital
		# Assumindo que o seu primeiro card de ministério mostra o capital político.
		capital_politico_label.text = str(capital)

# Função auxiliar para obter o nome do mês
func get_month_name(month_number: int) -> String:
	var month_names = ["", "JAN", "FEV", "MAR", "ABR", "MAI", "JUN", "JUL", "AGO", "SET", "OUT", "NOV", "DEZ"]
	if month_number >= 1 and month_number <= 12:
		return month_names[month_number]
	return "ERR"

# --- Funções para os Botões dos Ministérios ---

# func _on_planejamento_button_pressed():
#	print("CLICOU no Ministério do Planejamento!")
