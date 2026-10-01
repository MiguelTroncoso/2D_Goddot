class_name MitigationResolver
extends RefCounted

## Resolución de mitigación por tipo de daño (docs/design/03-combat.md §2.2).
##
## Fórmula: mitigación = DEF / (DEF + K), con K dependiente del tipo y del nivel
## del objetivo. El resultado se limita al 75 % para que ningún objetivo sea inmune.
## Capa: domain/ (lógica pura, sin nodos).

const CAP_MITIGACION := 0.75
const CAP_PENETRACION := 0.35
const K_FISICO_BASE := 50.0
const K_FISICO_POR_NIVEL := 10.0
const K_RESONANTE_BASE := 75.0
const K_RESONANTE_POR_NIVEL := 15.0
const NIVEL_MINIMO := 1


## Constante K de la curva de mitigación para un tipo y nivel de objetivo.
static func constante_k(nivel_objetivo: int, tipo: StringName) -> float:
	var nivel := maxi(nivel_objetivo, NIVEL_MINIMO)
	if tipo == DamageTypes.FISICO:
		return K_FISICO_BASE + K_FISICO_POR_NIVEL * nivel
	return K_RESONANTE_BASE + K_RESONANTE_POR_NIVEL * nivel


## Defensa efectiva tras aplicar penetración (los puntos se descuentan antes de la curva).
static func defensa_efectiva(defensa: float, penetracion: float = 0.0) -> float:
	var penetracion_limitada := clampf(penetracion, 0.0, CAP_PENETRACION)
	return maxf(0.0, defensa) * (1.0 - penetracion_limitada)


## Mitigación final en rango [0, 0.75]. Defensa <= 0 no mitiga nada.
static func mitigacion(defensa: float, nivel_objetivo: int, tipo: StringName) -> float:
	if defensa <= 0.0:
		return 0.0
	var k := constante_k(nivel_objetivo, tipo)
	if k <= 0.0:
		return 0.0
	return minf(defensa / (defensa + k), CAP_MITIGACION)


## Aplica mitigación a un daño ya calculado. Devuelve el daño tras mitigar.
static func aplicar(
	dano: float,
	defensa: float,
	nivel_objetivo: int,
	tipo: StringName,
	penetracion: float = 0.0
) -> float:
	var def_efectiva := defensa_efectiva(defensa, penetracion)
	return dano * (1.0 - mitigacion(def_efectiva, nivel_objetivo, tipo))


## Desglose auditable para tests y telemetría del servidor.
static func desglosar(
	dano: float,
	defensa: float,
	nivel_objetivo: int,
	tipo: StringName,
	penetracion: float = 0.0
) -> Dictionary:
	var def_efectiva := defensa_efectiva(defensa, penetracion)
	var mitigacion_final := mitigacion(def_efectiva, nivel_objetivo, tipo)
	return {
		"tipo": tipo,
		"defensa": defensa,
		"defensa_efectiva": def_efectiva,
		"penetracion": clampf(penetracion, 0.0, CAP_PENETRACION),
		"k": constante_k(nivel_objetivo, tipo),
		"mitigacion": mitigacion_final,
		"dano_tras_mitigar": dano * (1.0 - mitigacion_final),
	}
