class_name AiPatterns
extends RefCounted

## Decisiones de IA de criaturas (docs/design/03-combat.md §9).
##
## Alcance de TASK-004: **tres patrones** (pasivo, agresivo, patrulla). Los otros seis
## del GDD quedan declarados en `PATRONES_PENDIENTES` y se implementan en TASK-004.1;
## pedir uno de ellos devuelve una decisión segura marcada con `no_implementado` en
## lugar de fallar.
##
## Puro: recibe un contexto (distancias, vida, radios) y devuelve una decisión. No
## conoce nodos, red ni UI. El estado persistente lo lleva `systems/ai_system.gd`.

const PATRONES_IMPLEMENTADOS := [&"pasivo", &"agresivo", &"patrulla"]
const PATRONES_PENDIENTES := [
	&"errante", &"territorial", &"manada", &"emboscada", &"guardian", &"jefe",
]

const ESTADO_IDLE := &"idle"
const ESTADO_PATRULLAR := &"patrullar"
const ESTADO_PERSEGUIR := &"perseguir"
const ESTADO_ATACAR := &"atacar"
const ESTADO_HUIR := &"huir"
const ESTADO_VOLVER := &"volver"
const ESTADO_NO_IMPLEMENTADO := &"no_implementado"

const PATRON_POR_DEFECTO := &"pasivo"
const VIDA_HUIR := 0.20


static func esta_implementado(patron: StringName) -> bool:
	return PATRONES_IMPLEMENTADOS.has(patron)


static func es_valido(patron: StringName) -> bool:
	return PATRONES_IMPLEMENTADOS.has(patron) or PATRONES_PENDIENTES.has(patron)


static func normalizar(patron: StringName) -> StringName:
	if es_valido(patron):
		return patron
	return PATRON_POR_DEFECTO


static func patrones_implementados() -> Array:
	return PATRONES_IMPLEMENTADOS.duplicate()


static func patrones_pendientes() -> Array:
	return PATRONES_PENDIENTES.duplicate()


static func estado_inicial(patron: StringName) -> StringName:
	if normalizar(patron) == &"patrulla":
		return ESTADO_PATRULLAR
	return ESTADO_IDLE


## Decisión pura para un patrón y un contexto de combate.
##
## Entrada (opcional salvo `distancia` y `radio_ataque`):
##   distancia, vida_pct, objetivo_valido, en_combate, radio_deteccion,
##   radio_agarre, radio_ataque, tiempo, semilla, posicion_actual,
##   posicion_objetivo, posicion_guardia
##
## Salida: `estado`, `mover_hacia` (Vector2 normalizado o cero), `atacar`,
## `llamar_aliados`, `invocar`, `fase`, `no_implementado`.
static func decidir(patron: StringName, contexto: Dictionary) -> Dictionary:
	var c := _contexto(contexto)
	if not esta_implementado(patron):
		return _decision(
			ESTADO_NO_IMPLEMENTADO,
			Vector2.ZERO,
			false,
			{"no_implementado": true, "patron_pendiente": normalizar(patron)}
		)
	match patron:
		&"pasivo":
			return _decidir_pasivo(c)
		&"agresivo":
			return _decidir_agresivo(c)
		_:
			return _decidir_patrulla(c)


static func _contexto(contexto: Dictionary) -> Dictionary:
	return {
		"distancia": float(contexto.get("distancia", INF)),
		"vida_pct": clampf(float(contexto.get("vida_pct", 1.0)), 0.0, 1.0),
		"objetivo_valido": bool(contexto.get("objetivo_valido", false)),
		"en_combate": bool(contexto.get("en_combate", false)),
		"radio_deteccion": float(contexto.get("radio_deteccion", 5.0)),
		"radio_agarre": float(contexto.get("radio_agarre", 10.0)),
		"radio_ataque": float(contexto.get("radio_ataque", 1.5)),
		"tiempo": float(contexto.get("tiempo", 0.0)),
		"semilla": float(contexto.get("semilla", 0.0)),
		"posicion_actual": contexto.get("posicion_actual", Vector2.ZERO),
		"posicion_objetivo": contexto.get("posicion_objetivo", Vector2.ZERO),
		"posicion_guardia": contexto.get("posicion_guardia", Vector2.ZERO),
	}


static func _decision(
	estado: StringName,
	hacia: Vector2 = Vector2.ZERO,
	atacar: bool = false,
	extras: Dictionary = {}
) -> Dictionary:
	var decision := {
		"estado": estado,
		"mover_hacia": hacia.normalized() if hacia.length() > 0.001 else Vector2.ZERO,
		"atacar": atacar,
		"llamar_aliados": false,
		"invocar": false,
		"fase": 1,
		"no_implementado": false,
	}
	for clave in extras:
		decision[clave] = extras[clave]
	return decision


static func _hacia_objetivo(c: Dictionary) -> Vector2:
	return c["posicion_objetivo"] - c["posicion_actual"]


static func _hacia_guardia(c: Dictionary) -> Vector2:
	return c["posicion_guardia"] - c["posicion_actual"]


static func _detecta(c: Dictionary) -> bool:
	return c["objetivo_valido"] and c["distancia"] <= c["radio_deteccion"]


static func _fuera_de_agarre(c: Dictionary) -> bool:
	return c["distancia"] > c["radio_agarre"]


static func _direccion_determinista(c: Dictionary, frecuencia: float) -> Vector2:
	var t: float = float(c["tiempo"]) * frecuencia + float(c["semilla"])
	return Vector2(cos(t), sin(t * 1.37))


## Pasivo: no reacciona hasta recibir daño; huye si queda muy herido.
static func _decidir_pasivo(c: Dictionary) -> Dictionary:
	if not c["en_combate"]:
		return _decision(ESTADO_IDLE)
	if c["vida_pct"] <= VIDA_HUIR:
		return _decision(ESTADO_HUIR, -_hacia_objetivo(c))
	if c["distancia"] <= c["radio_ataque"]:
		return _decision(ESTADO_ATACAR, _hacia_objetivo(c), true)
	return _decision(ESTADO_PERSEGUIR, _hacia_objetivo(c))


## Agresivo: detecta, persigue hasta el leash y ataca; vuelve a su puesto al alejarse.
static func _decidir_agresivo(c: Dictionary) -> Dictionary:
	if not c["objetivo_valido"]:
		return _decision(ESTADO_IDLE)
	if _fuera_de_agarre(c):
		return _decision(ESTADO_VOLVER, _hacia_guardia(c))
	if c["distancia"] <= c["radio_ataque"]:
		return _decision(ESTADO_ATACAR, _hacia_objetivo(c), true)
	if _detecta(c) or c["en_combate"]:
		return _decision(ESTADO_PERSEGUIR, _hacia_objetivo(c))
	return _decision(ESTADO_IDLE)


## Patrulla: recorre una dirección determinista hasta detectar; luego se comporta como agresivo.
static func _decidir_patrulla(c: Dictionary) -> Dictionary:
	if _detecta(c):
		return _decidir_agresivo(c)
	var tramo := int(c["tiempo"] / 3.0)
	return _decision(
		ESTADO_PATRULLAR,
		_direccion_determinista({"tiempo": float(tramo), "semilla": c["semilla"]}, 1.0)
	)
