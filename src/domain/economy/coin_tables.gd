class_name CoinTables
extends RefCounted

## Rangos de Cobre por tramo (docs/design/05-economy.md §2.1).
##
## Puro y determinista: el sistema de botín entrega la tirada, el dominio decide
## cuánto Cobre corresponde. Capa: domain/.

## Tramo 1–10: [mínimo, máximo] de una criatura común.
const RANGOS_POR_TRAMO := [
	[3, 20],
	[20, 80],
	[60, 260],
	[150, 700],
	[350, 1600],
	[750, 3600],
	[1600, 7500],
	[3200, 15000],
	[6500, 30000],
	[13000, 62000],
]

const MULTIPLICADOR_TIPO := {
	&"comun": 1.0,
	&"elite": 3.0,
	&"minijefe": 8.0,
	&"jefe_tramo": 25.0,
	&"jefe_instancia": 18.0,
	&"jefe_raid": 30.0,
	&"jefe_mundial": 30.0,
}


static func tramo_de_nivel(nivel: int) -> int:
	var nivel_actual := clampi(nivel, 1, 150)
	return int((nivel_actual - 1) / 15) + 1


static func rango_por_tramo(tramo: int) -> Array:
	var indice := clampi(tramo, 1, RANGOS_POR_TRAMO.size()) - 1
	return RANGOS_POR_TRAMO[indice]


static func rango_para_nivel(nivel: int) -> Array:
	return rango_por_tramo(tramo_de_nivel(nivel))


static func multiplicador_tipo(tipo_mob: StringName) -> float:
	return float(MULTIPLICADOR_TIPO.get(tipo_mob, 1.0))


## Cobre que suelta una criatura. `tirada` es un valor [0, 1) inyectado por el servidor.
static func calcular(nivel: int, tipo_mob: StringName, tirada: float) -> int:
	var rango := rango_para_nivel(nivel)
	var t := clampf(tirada, 0.0, 0.999999)
	var base := float(rango[0]) + (float(rango[1]) - float(rango[0])) * t
	return int(round(base * multiplicador_tipo(tipo_mob)))


## Techo de Cobre para una criatura (sin tirada).
static func maximo(nivel: int, tipo_mob: StringName) -> int:
	var rango := rango_para_nivel(nivel)
	return int(round(float(rango[1]) * multiplicador_tipo(tipo_mob)))
