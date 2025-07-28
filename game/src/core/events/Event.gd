# Event.gd - Classe base para todos os eventos do jogo
extends Resource
class_name GameEvent

var type
var data: Dictionary
var timestamp: float
var source: String

func _init(p_type, p_data: Dictionary, p_source: String):
	type = p_type
	data = p_data
	timestamp = Time.get_ticks_msec() / 1000.0
	source = p_source
