class_name AiSystem
extends RefCounted

## Orquestación de IA: mantiene el estado por criatura (estado actual, fase de jefe)
## y delega la decisión a `domain/ai/ai_patterns.gd`.
##
## No conoce nodos ni presentación: devuelve decisiones y emite señales (ADR-005).

signal estado_cambiado(evento: Dictionary)
signal fase_cambiada(evento: Dictionary)

var _estados: Dictionary = {}
var _fases: Dictionary = {}
var _decisiones: int = 0


## Pide una decisión para una criatura. Añade a la respuesta el estado previo y
## marca `invocar` solo en la transición de fase de un jefe (no en cada frame).
func decidir(id: StringName, patron: StringName, contexto: Dictionary) -> Dictionary:
	var decision := AiPatterns.decidir(patron, contexto)
	_decisiones += 1

	var estado_nuevo: StringName = decision["estado"]
	var estado_previo: StringName = _estados.get(id, AiPatterns.estado_inicial(patron))
	if estado_nuevo != estado_previo:
		estados_registrados(id, estado_nuevo)
		estado_cambiado.emit({
			"id": id,
			"patron": AiPatterns.normalizar(patron),
			"estado_anterior": estado_previo,
			"estado": estado_nuevo,
		})
	decision["estado_anterior"] = estado_previo

	var fase_nueva := int(decision.get("fase", 1))
	var fase_previa := int(_fases.get(id, 1))
	if fase_nueva != fase_previa:
		_fases[id] = fase_nueva
		fase_cambiada.emit({"id": id, "fase_anterior": fase_previa, "fase": fase_nueva})
	var invocar := bool(decision.get("invocar", false)) and fase_nueva > fase_previa
	decision["invocar"] = invocar
	decision["fase_anterior"] = fase_previa
	return decision


## Registra el estado sin emitir señal (útil al inicializar una criatura).
func estados_registrados(id: StringName, estado: StringName) -> void:
	_estados[id] = estado


func estado_actual(id: StringName) -> StringName:
	return _estados.get(id, &"")


func fase_actual(id: StringName) -> int:
	return int(_fases.get(id, 1))


func decisiones_tomadas() -> int:
	return _decisiones


func olvidar(id: StringName) -> void:
	_estados.erase(id)
	_fases.erase(id)


func reiniciar() -> void:
	_estados.clear()
	_fases.clear()
	_decisiones = 0
