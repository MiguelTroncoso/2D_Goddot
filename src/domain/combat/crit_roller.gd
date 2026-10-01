class_name CritRoller
extends RefCounted

## Resolución de críticos (docs/design/03-combat.md §2.3).
##
## La tirada entra como parámetro [0, 1) para que el cálculo sea determinista y
## auditable: el servidor genera el número, el dominio decide. Nunca usa RNG global.
## Capa: domain/ (lógica pura).

const CAP_PROBABILIDAD := 0.50
const PROBABILIDAD_BASE := 0.05
const MULTIPLICADOR_BASE := 1.50
const CAP_MULTIPLICADOR := 2.50


## Probabilidad final de crítico, limitada al 50 %.
static func probabilidad(base: float = PROBABILIDAD_BASE, equipo: float = 0.0, buff: float = 0.0) -> float:
	return clampf(base + equipo + buff, 0.0, CAP_PROBABILIDAD)


## Multiplicador final de daño crítico, limitado al 250 %.
static func multiplicador(extra: float = 0.0) -> float:
	return clampf(MULTIPLICADOR_BASE + extra, 1.0, CAP_MULTIPLICADOR)


## Resuelve una tirada determinista. La tirada es crítica si es estrictamente menor
## que la probabilidad: con probabilidad 0 nunca hay crítico y con probabilidad 1
## (imposible por el cap) siempre lo habría.
static func resolver(
	probabilidad_final: float,
	multiplicador_final: float,
	tirada: float
) -> Dictionary:
	var probabilidad_limitada := clampf(probabilidad_final, 0.0, CAP_PROBABILIDAD)
	var multiplicador_limitado := clampf(multiplicador_final, 1.0, CAP_MULTIPLICADOR)
	var es_critico := tirada < probabilidad_limitada
	return {
		"es_critico": es_critico,
		"probabilidad": probabilidad_limitada,
		"multiplicador": multiplicador_limitado if es_critico else 1.0,
		"tirada": tirada,
	}


## Atajo: calcula probabilidad y multiplicador desde sus componentes y resuelve.
static func tirar(
	critico_base: float,
	critico_equipo: float,
	critico_buff: float,
	dano_critico_extra: float,
	tirada: float
) -> Dictionary:
	return resolver(
		probabilidad(critico_base, critico_equipo, critico_buff),
		multiplicador(dano_critico_extra),
		tirada
	)


## Aplica el resultado de [method resolver] a un daño ya calculado.
static func aplicar(dano: float, resultado: Dictionary) -> float:
	return dano * float(resultado.get("multiplicador", 1.0))
