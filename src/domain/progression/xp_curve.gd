class_name XpCurve
extends RefCounted

## Curva de experiencia canónica (docs/design/06-progression.md §1).
##
##   XP_para_subir(L) = round(40 × L² + 25 × L)      con L en [1, 150]
##   XP total hasta 150 = 44.830.375
##
## Capa: domain/ (lógica pura, sin nodos, sin red).

const NIVEL_MINIMO := 1
const NIVEL_MAXIMO := 150
const XP_TOTAL_A_150 := 44_830_375
const NIVELES_POR_TRAMO := 15

## Multiplicadores de XP por tipo de encuentro (06-progression.md §1.3).
const MULTIPLICADORES_TIPO := {
	&"comun": 1.0,
	&"elite": 3.0,
	&"minijefe": 8.0,
	&"jefe_tramo": 25.0,
	&"jefe_instancia": 18.0,
	&"jefe_raid": 60.0,
	&"jefe_mundial": 60.0,
}


## Limita un nivel a la escala 1–150. Los bordes son válidos; nada lanza error.
static func nivel_limitado(nivel: int) -> int:
	return clampi(nivel, NIVEL_MINIMO, NIVEL_MAXIMO)


## Tramo (1–10) al que pertenece el nivel.
static func tramo_de_nivel(nivel: int) -> int:
	return int((nivel_limitado(nivel) - 1) / NIVELES_POR_TRAMO) + 1


static func es_nivel_maximo(nivel: int) -> bool:
	return nivel_limitado(nivel) >= NIVEL_MAXIMO


## XP necesaria para pasar del nivel dado al siguiente.
static func xp_para_subir(nivel: int) -> int:
	var l := float(nivel_limitado(nivel))
	return int(round(40.0 * l * l + 25.0 * l))


## XP acumulada necesaria para *estar* en [param hasta_nivel]:
## suma de los niveles 1..hasta_nivel−1. En el nivel 1 vale 0.
static func xp_acumulada(hasta_nivel: int) -> int:
	var objetivo := nivel_limitado(hasta_nivel)
	var total := 0
	for nivel in range(NIVEL_MINIMO, objetivo):
		total += xp_para_subir(nivel)
	return total


## XP que otorga una criatura común del nivel dado, antes de modificar por diferencia.
static func xp_criatura(nivel_criatura: int, tipo: StringName = &"comun") -> int:
	var base := 0.012 * float(xp_para_subir(nivel_criatura))
	var factor := float(MULTIPLICADORES_TIPO.get(tipo, 1.0))
	return int(round(base * factor))


## Multiplicador por diferencia de nivel (criatura − jugador), 06-progression.md §1.3.
static func multiplicador_diferencia_nivel(diferencia: int) -> float:
	if diferencia >= 8:
		return 1.15
	if diferencia >= -3:
		return 1.0
	if diferencia >= -8:
		return 0.6
	if diferencia >= -14:
		return 0.25
	return 0.0


## XP final que recibe un jugador por derrotar una criatura, según su tipo y nivel.
static func xp_ajustada(
	nivel_criatura: int,
	nivel_jugador: int,
	tipo: StringName = &"comun"
) -> int:
	var diferencia := nivel_limitado(nivel_criatura) - nivel_limitado(nivel_jugador)
	var factor := multiplicador_diferencia_nivel(diferencia)
	if factor <= 0.0:
		return 0
	return int(round(float(xp_criatura(nivel_criatura, tipo)) * factor))


## Tipos de encuentro soportados por la tabla de multiplicadores.
static func tipos_soportados() -> Array:
	return MULTIPLICADORES_TIPO.keys()
