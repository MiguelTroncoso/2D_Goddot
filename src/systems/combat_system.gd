class_name CombatSystem
extends RefCounted

## Orquestación de combate (docs/design/03-combat.md §3).
##
## Responsabilidad: mantener actores, cooldowns y eventos; delegar TODA la
## aritmética a `domain/combat/*`. No conoce nodos, ni UI, ni red: se comunica
## por señales y retornos (ADR-005).

signal dano_aplicado(evento: Dictionary)
signal curacion_aplicada(evento: Dictionary)
signal actor_derrotado(evento: Dictionary)

var _actores: Dictionary = {}
var _cooldowns: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _eventos: int = 0


## `semilla` 0 = aleatorio; cualquier otro valor fija una secuencia reproducible
## para que los tests y la verificación del servidor sean deterministas.
func _init(semilla: int = 0) -> void:
	if semilla == 0:
		_rng.randomize()
	else:
		_rng.seed = semilla


# ------------------------------------------------------------------ registro

func registrar_actor(
	id: StringName,
	bando: StringName,
	stats: StatBlock,
	vida_inicial: float = -1.0
) -> void:
	var vida := vida_inicial if vida_inicial >= 0.0 else float(stats.vida_max())
	_actores[id] = {
		"bando": bando,
		"stats": stats,
		"vida": vida,
		"vida_max": float(stats.vida_max()),
	}


func desregistrar_actor(id: StringName) -> void:
	_actores.erase(id)
	for clave in _cooldowns.keys():
		if String(clave).begins_with("%s|" % id):
			_cooldowns.erase(clave)


func actores() -> Array:
	return _actores.keys()


func tiene_actor(id: StringName) -> bool:
	return _actores.has(id)


func stats(id: StringName) -> StatBlock:
	return _actores[id]["stats"] if _actores.has(id) else null


func bando(id: StringName) -> StringName:
	return _actores[id]["bando"] if _actores.has(id) else &""


func vida(id: StringName) -> float:
	return float(_actores[id]["vida"]) if _actores.has(id) else 0.0


func vida_max(id: StringName) -> float:
	return float(_actores[id]["vida_max"]) if _actores.has(id) else 0.0


func vida_porcentaje(id: StringName) -> float:
	if not _actores.has(id):
		return 0.0
	var maxima := float(_actores[id]["vida_max"])
	if maxima <= 0.0:
		return 0.0
	return clampf(float(_actores[id]["vida"]) / maxima, 0.0, 1.0)


func esta_vivo(id: StringName) -> bool:
	return _actores.has(id) and float(_actores[id]["vida"]) > 0.0


func eventos_emitidos() -> int:
	return _eventos


# ------------------------------------------------------------------ cooldowns

func _clave_cooldown(id: StringName, habilidad: StringName) -> String:
	return "%s|%s" % [id, habilidad]


func puede_atacar(id: StringName, habilidad: StringName, tiempo: float = 0.0) -> bool:
	if not esta_vivo(id):
		return false
	return tiempo >= float(_cooldowns.get(_clave_cooldown(id, habilidad), -1.0))


func enfriamiento_restante(id: StringName, habilidad: StringName, tiempo: float = 0.0) -> float:
	var disponible := float(_cooldowns.get(_clave_cooldown(id, habilidad), -1.0))
	return maxf(0.0, disponible - tiempo)


func reiniciar_cooldowns(id: StringName) -> void:
	for clave in _cooldowns.keys():
		if String(clave).begins_with("%s|" % id):
			_cooldowns.erase(clave)


# ------------------------------------------------------------------- acciones

## Resuelve un ataque completo. `datos` admite:
##   habilidad (StringName), coef, tipo, cooldown, plano, bono_negativo,
##   mods_estado, mods_pvp, ignorar_cooldown.
## Devuelve el desglose de `DamageCalculator` más el resultado del impacto.
func atacar(
	atacante_id: StringName,
	objetivo_id: StringName,
	datos: Dictionary,
	tiempo: float = 0.0
) -> Dictionary:
	var habilidad: StringName = datos.get("habilidad", &"basico")
	if not esta_vivo(atacante_id):
		return _fallo("atacante_no_disponible", atacante_id, objetivo_id, habilidad)
	if not esta_vivo(objetivo_id):
		return _fallo("objetivo_no_disponible", atacante_id, objetivo_id, habilidad)
	var ignorar: bool = bool(datos.get("ignorar_cooldown", false))
	if not ignorar and not puede_atacar(atacante_id, habilidad, tiempo):
		return _fallo("en_enfriamiento", atacante_id, objetivo_id, habilidad)

	var cooldown := float(datos.get("cooldown", 0.0))
	if not ignorar and cooldown > 0.0:
		_cooldowns[_clave_cooldown(atacante_id, habilidad)] = tiempo + cooldown

	var atacante := stats(atacante_id)
	var objetivo := stats(objetivo_id)
	var mods_pvp := float(datos.get("mods_pvp", 0.6 if _es_pvp(atacante_id, objetivo_id) else 1.0))
	var golpe := {
		"pod": atacante.pod_total(),
		"coef": float(datos.get("coef", 1.0)),
		"nivel_lanzador": atacante.nivel,
		"defensa_objetivo": objetivo.def_total(),
		"nivel_objetivo": objetivo.nivel,
		"tipo": datos.get("tipo", DamageTypes.FISICO),
		"penetracion": atacante.penetracion(),
		"bono_negativo": float(datos.get("bono_negativo", 0.0)),
		"mods_estado": float(datos.get("mods_estado", 1.0)),
		"mods_pvp": mods_pvp,
		"critico_base": atacante.critico(),
		"dano_critico_extra": atacante.multiplicador_critico() - CritRoller.MULTIPLICADOR_BASE,
		"tirada_critico": _rng.randf(),
	}
	if datos.has("plano"):
		golpe["plano"] = float(datos["plano"])

	var resultado := DamageCalculator.resolver(golpe)
	var dano := float(resultado["dano_final"])
	return _aplicar_resultado(atacante_id, objetivo_id, habilidad, dano, resultado)


## Daño ya resuelto (DoT, entorno, caída). No pasa por crítico ni por armas.
func aplicar_dano(
	atacante_id: StringName,
	objetivo_id: StringName,
	cantidad: float,
	tipo: StringName = DamageTypes.FISICO,
	etiqueta: StringName = &"directo"
) -> Dictionary:
	if not esta_vivo(objetivo_id):
		return _fallo("objetivo_no_disponible", atacante_id, objetivo_id, etiqueta)
	var objetivo := stats(objetivo_id)
	var mitigado := MitigationResolver.aplicar(
		cantidad,
		objetivo.def_total(),
		objetivo.nivel,
		tipo
	)
	var resultado := {
		"dano_base": cantidad,
		"tipo": tipo,
		"mitigacion": MitigationResolver.mitigacion(objetivo.def_total(), objetivo.nivel, tipo),
		"es_critico": false,
		"multiplicador_critico": 1.0,
		"dano_final": mitigado,
		"dano_final_entero": int(round(mitigado)),
	}
	return _aplicar_resultado(atacante_id, objetivo_id, etiqueta, mitigado, resultado)


func curar(id: StringName, cantidad: float, fuente: StringName = &"desconocida") -> Dictionary:
	if not _actores.has(id):
		return {"exito": false, "razon": "actor_no_disponible", "objetivo": id}
	var maxima := float(_actores[id]["vida_max"])
	var antes := float(_actores[id]["vida"])
	_actores[id]["vida"] = minf(maxima, antes + maxf(0.0, cantidad))
	var evento := {
		"exito": true,
		"objetivo": id,
		"fuente": fuente,
		"curado": float(_actores[id]["vida"]) - antes,
		"vida_restante": float(_actores[id]["vida"]),
	}
	_eventos += 1
	curacion_aplicada.emit(evento)
	return evento


func _es_pvp(a: StringName, b: StringName) -> bool:
	return bando(a) == &"jugador" and bando(b) == &"jugador"


func _fallo(razon: String, atacante: StringName, objetivo: StringName, habilidad: StringName) -> Dictionary:
	return {
		"exito": false,
		"razon": razon,
		"atacante": atacante,
		"objetivo": objetivo,
		"habilidad": habilidad,
		"dano_final": 0.0,
		"dano_final_entero": 0,
	}


func _aplicar_resultado(
	atacante_id: StringName,
	objetivo_id: StringName,
	habilidad: StringName,
	dano: float,
	resultado: Dictionary
) -> Dictionary:
	var vida_antes := float(_actores[objetivo_id]["vida"])
	var vida_despues := maxf(0.0, vida_antes - maxf(0.0, dano))
	_actores[objetivo_id]["vida"] = vida_despues
	var derrotado := vida_despues <= 0.0
	var evento := {
		"exito": true,
		"atacante": atacante_id,
		"objetivo": objetivo_id,
		"habilidad": habilidad,
		"dano": dano,
		"dano_entero": int(resultado.get("dano_final_entero", round(dano))),
		"tipo": resultado.get("tipo", DamageTypes.FISICO),
		"es_critico": bool(resultado.get("es_critico", false)),
		"mitigacion": float(resultado.get("mitigacion", 0.0)),
		"vida_antes": vida_antes,
		"vida_restante": vida_despues,
		"objetivo_derrotado": derrotado,
		"desglose": resultado,
	}
	_eventos += 1
	dano_aplicado.emit(evento)
	if derrotado:
		actor_derrotado.emit(evento)
	return evento
