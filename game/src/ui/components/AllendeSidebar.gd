# AllendeSidebar.gd
extends Control

# === NODE REFERENCES ===
@onready var date_label: Label = $VBoxContainer/DateLabel
@onready var phase_label: Label = $VBoxContainer/PhaseLabel
@onready var time_control_button: Button = $VBoxContainer/TimeControlButton
@onready var planning_button: Button = $VBoxContainer/PlanningButton
@onready var reforms_button: Button = $VBoxContainer/ReformsButton
@onready var history_button: Button = $VBoxContainer/HistoryButton

# === STATE ===
var is_paused: bool = true

func _ready() -> void:
    # Subscribe to relevant events
    EventBus.subscribe(EventTypes.Type.DAY_PASSED, self, "_on_day_passed")
    EventBus.subscribe(EventTypes.Type.PHASE_CHANGED, self, "_on_phase_changed")
    EventBus.subscribe(EventTypes.Type.GAME_STARTED, self, "_on_game_started")

    # Connect button signals
    time_control_button.pressed.connect(_on_time_control_pressed)
    planning_button.pressed.connect(_on_planning_pressed)
    reforms_button.pressed.connect(_on_reforms_pressed)
    history_button.pressed.connect(_on_history_pressed)

    _update_time_control_button()

# === EVENT HANDLERS ===
func _on_game_started(event) -> void:
    var game_data = event.data
    if game_data and game_data.has("current_date"):
        _update_date_label(game_data.current_date)
    if game_data and game_data.has("historical_phase"):
        _update_phase_label(game_data.historical_phase)

func _on_day_passed(event) -> void:
    var new_date = event.data
    _update_date_label(new_date)

func _on_phase_changed(event) -> void:
    var new_phase = event.data
    _update_phase_label(new_phase)

# === UI UPDATE FUNCTIONS ===
func _update_date_label(date: Dictionary) -> void:
    if date_label:
        date_label.text = Calendar.date_to_string(date)

func _update_phase_label(phase: int) -> void:
    if phase_label:
        phase_label.text = "Fase: " + Calendar.get_phase_name(phase)

func _update_time_control_button() -> void:
    if time_control_button:
        time_control_button.text = "Pausar" if not is_paused else "Continuar"

# === BUTTON CALLBACKS ===
func _on_time_control_pressed() -> void:
    is_paused = not is_paused
    _update_time_control_button()
    if is_paused:
        EventBus.emit_event(EventTypes.Type.TIME_PAUSED, {}, "AllendeSidebar")
    else:
        EventBus.emit_event(EventTypes.Type.TIME_RESUMED, {}, "AllendeSidebar")

func _on_planning_pressed() -> void:
    EventBus.emit_event(EventTypes.Type.POPUP_REQUESTED, {"type": "planning"}, "AllendeSidebar")

func _on_reforms_pressed() -> void:
    EventBus.emit_event(EventTypes.Type.POPUP_REQUESTED, {"type": "reforms"}, "AllendeSidebar")

func _on_history_pressed() -> void:
    EventBus.emit_event(EventTypes.Type.POPUP_REQUESTED, {"type": "history"}, "AllendeSidebar")
