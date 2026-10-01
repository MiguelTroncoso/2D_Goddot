class_name DamageCalculator
extends RefCounted

## Fórmula canónica de daño (docs/design/03-combat.md §2 y §2.5).
##
##   daño_base  = (POD × coef + plano) × (1 + 0,02 × (nivel_lanzador − 1))
##   daño_final = daño_base × (1 − mitigación) × (1 + bono_negativo)
##                × mods_estado × mods_pvp × multiplicador_crítico
##
## Todo el cálculo es puro y devuelve un desglose auditable; el servidor decide y
## el cliente nunca calcula resultados (ADR-002).
## Capa: domain/ (sin nodos, sin red, sin UI).

const CAP_BONO_NEGATIVO := 0.40
const FACTOR_NIVEL_POR_PUNTO := 0.02
const NIVEL_MINIMO := 1
const NIVEL_MAXIMO := 150

## Tabla de plano por tramo (03-combat.md §2.5). Cada entrada arranca donde termina la anterior.
const TRAMOS_PLANO := [
	{"tramo": 1, "nivel_min": 1, "nivel_max": 15, "base": 6.0, "pendiente": 1.5, "nivel_base": 1},
	{"tramo": 2, "nivel_min": 16, "nivel_max": 30, "base": 27.0, "pendiente": 2.6, "nivel_base": 15},
	{"tramo": 3, "nivel_min": 31, "nivel_max": 45, "base": 66.0, "pendiente": 4.5, "nivel_base": 30},
	{"tramo": 4, "nivel_min": 46, "nivel_max": 60, "base": 133.0, "pendiente": 7.5, "nivel_base": 45},
	{"tramo": 5, "nivel_min": 61, "nivel_max": 75, "base": 245.0, "pendiente": 12.0, "nivel_base": 60},
	{"tramo": 6, "nivel_min": 76, "nivel_max": 90, "base": 425.0, "pendiente": 19.0, "nivel_base": 75},
	{"tramo": 7, "nivel_min": 91, "nivel_max": 105, "base": 710.0, "pendiente": 30.0, "nivel_base": 90},
	{"tramo": 8, "nivel_min": 106, "nivel_max": 120, "base": 1160.0, "pendiente": 47.0, "nivel_base": 105},
	{"tramo": 9, "nivel_min": 121, "nivel_max": 135, "base": 1865.0, "pendiente": 74.0, "nivel_base": 120},
	{"tramo": 10, "nivel_min": 136, "nivel_max": 150, "base": 2975.0, "pendiente": 116.0, "nivel_base": 135},
]


## Nivel válido dentro de la escala 1–150 (se limita en los bordes).
static func nivel_limitado(nivel: int) -> int:
	return clampi(nivel, NIVEL_MINIMO, NIVEL_MAXIMO)


## Tramo (1–10) al que pertenece un nivel.
static func tramo_de_nivel(nivel: int) -> int:
	var nivel_actual := nivel_limitado(nivel)
	return int((nivel_actual - 1) / 15) + 1


## Entrada de la tabla de plano correspondiente al nivel.
static func tabla_plano(nivel: int) -> Dictionary:
	for entrada in TRAMOS_PLANO:
		if nivel <= int(entrada["nivel_max"]):
			return entrada
	return TRAMOS_PLANO[TRAMOS_PLANO.size() - 1]


## Plano de una habilidad para un nivel y coeficiente dados.
static func plano_habilidad(nivel: int, coef: float = 1.0) -> float:
	var entrada := tabla_plano(nivel_limitado(nivel))
	var nivel_base := int(entrada["nivel_base"])
	var pendiente := float(entrada["pendiente"])
	var base := float(entrada["base"])
	var plano := base + pendiente * float(nivel_limitado(nivel) - nivel_base)
	return plano * coef


## Factor de escalado por nivel del lanzador: 1 + 0,02 × (nivel − 1).
static func factor_nivel(nivel_lanzador: int) -> float:
	return 1.0 + FACTOR_NIVEL_POR_PUNTO * float(nivel_limitado(nivel_lanzador) - 1)


## Daño antes de mitigación, crítico y modificadores.
static func dano_base(pod: float, coef: float, plano: float, nivel_lanzador: int) -> float:
	return (pod * coef + plano) * factor_nivel(nivel_lanzador)


## Reducción de resistencia acumulada, limitada al 40 %.
static func bono_negativo(valor: float) -> float:
	return clampf(valor, 0.0, CAP_BONO_NEGATIVO)


## Resolución completa de un golpe.
##
## Entrada (Dictionary):
##   pod: float · coef: float · nivel_lanzador: int
##   plano: float (opcional; si falta se calcula con la tabla del tramo)
##   defensa_objetivo: float · nivel_objetivo: int · tipo: StringName
##   bono_negativo: float (opcional) · penetracion: float (opcional)
##   mods_estado: float (opcional, por defecto 1.0)
##   mods_pvp: float (opcional, por defecto 1.0)
##   critico_probabilidad / critico_multiplicador / tirada_critico (opcionales)
##
## Salida: desglose completo más `dano_final` (float) y `dano_final_entero` (int).
static func resolver(golpe: Dictionary) -> Dictionary:
	var pod := float(golpe.get("pod", 0.0))
	var coef := float(golpe.get("coef", 1.0))
	var nivel_lanzador := nivel_limitado(int(golpe.get("nivel_lanzador", 1)))
	var nivel_objetivo := nivel_limitado(int(golpe.get("nivel_objetivo", 1)))
	var defensa := float(golpe.get("defensa_objetivo", 0.0))
	var tipo: StringName = golpe.get("tipo", DamageTypes.FISICO)
	var penetracion := float(golpe.get("penetracion", 0.0))
	var modificador_negativo := bono_negativo(float(golpe.get("bono_negativo", 0.0)))
	var mods_estado := float(golpe.get("mods_estado", 1.0))
	var mods_pvp := float(golpe.get("mods_pvp", 1.0))
	var plano := float(golpe.get("plano", plano_habilidad(nivel_lanzador, coef)))

	var dano_sin_mitigar := dano_base(pod, coef, plano, nivel_lanzador)
	var mitigacion_info := MitigationResolver.desglosar(dano_sin_mitigar, defensa, nivel_objetivo, tipo, penetracion)
	var dano_tras_mitigar := float(mitigacion_info["dano_tras_mitigar"])
	var dano_con_mods := dano_tras_mitigar * (1.0 + modificador_negativo) * mods_estado * mods_pvp

	var critico := {
		"es_critico": false,
		"probabilidad": 0.0,
		"multiplicador": 1.0,
		"tirada": 0.0,
	}
	if golpe.has("tirada_critico"):
		critico = CritRoller.tirar(
			float(golpe.get("critico_base", CritRoller.PROBABILIDAD_BASE)),
			float(golpe.get("critico_equipo", 0.0)),
			float(golpe.get("critico_buff", 0.0)),
			float(golpe.get("dano_critico_extra", 0.0)),
			float(golpe["tirada_critico"])
		)

	var dano_final := CritRoller.aplicar(dano_con_mods, critico)
	return {
		"pod": pod,
		"coef": coef,
		"plano": plano,
		"nivel_lanzador": nivel_lanzador,
		"nivel_objetivo": nivel_objetivo,
		"tipo": tipo,
		"factor_nivel": factor_nivel(nivel_lanzador),
		"dano_base": dano_sin_mitigar,
		"defensa_efectiva": mitigacion_info["defensa_efectiva"],
		"mitigacion": mitigacion_info["mitigacion"],
		"bono_negativo": modificador_negativo,
		"mods_estado": mods_estado,
		"mods_pvp": mods_pvp,
		"es_critico": critico["es_critico"],
		"multiplicador_critico": critico["multiplicador"],
		"dano_final": dano_final,
		"dano_final_entero": int(round(dano_final)),
	}
