class_name StatBlock
extends RefCounted

## Bloque de estadísticas de un actor (docs/design/02-classes.md §3.1 y 06-progression.md §3).
##
## Es un contenedor de datos con derivados puros: no conoce escenas, red ni UI.
## Todos los topes duros viven aquí para que cliente y servidor usen el mismo número.
## Capa: domain/ (lógica pura).

const NIVEL_MINIMO := 1
const NIVEL_MAXIMO := 150

const CRITICO_BASE := 0.05
const MULTIPLICADOR_CRITICO_BASE := 1.50
const VELOCIDAD_BASE := 4.0
const RESERVA_BASE := 100
const REGEN_COMBATE_BASE := 2.0
const REGEN_FUERA_COMBATE := 6.0

const VIDA_POR_VIGOR := 8.0
const DEF_POR_VIGOR := 2.0
const VIGOR_UMBRAL_DEF := 20
const POD_POR_PUNTO := 1.0
const CELERIDAD_POR_AGILIDAD := 0.0015
const VELOCIDAD_POR_AGILIDAD := 0.0001
const PENETRACION_POR_RESONANCIA := 0.01 / 30.0

const CAP_CRITICO := 0.50
const CAP_MULTIPLICADOR_CRITICO := 2.50
const CAP_CELERIDAD := 0.40
const CAP_TENACIDAD := 0.50
const CAP_PENETRACION := 0.35
const CAP_VELOCIDAD := 0.30

var nivel: int = NIVEL_MINIMO
var vigor: int = 0
var poder: int = 0
var resonancia: int = 0
var agilidad: int = 0

var critico_extra: float = 0.0
var dano_critico_extra: float = 0.0
var celeridad_extra: float = 0.0
var tenacidad_extra: float = 0.0
var penetracion_extra: float = 0.0
var velocidad_extra: float = 0.0
## Defensa adicional aportada por datos de criatura o equipo (no por atributos).
var defensa_extra: float = 0.0


## Bloque vacío del nivel indicado (atributos en cero, sin equipo).
static func base(nivel_actor: int = NIVEL_MINIMO) -> StatBlock:
	var bloque := StatBlock.new()
	bloque.nivel = clampi(nivel_actor, NIVEL_MINIMO, NIVEL_MAXIMO)
	return bloque


## Construye desde un diccionario (datos de `data/*.tres` o del servidor).
static func desde_diccionario(datos: Dictionary) -> StatBlock:
	var bloque := StatBlock.new()
	bloque.nivel = clampi(int(datos.get("nivel", NIVEL_MINIMO)), NIVEL_MINIMO, NIVEL_MAXIMO)
	bloque.vigor = int(datos.get("vigor", 0))
	bloque.poder = int(datos.get("poder", 0))
	bloque.resonancia = int(datos.get("resonancia", 0))
	bloque.agilidad = int(datos.get("agilidad", 0))
	bloque.critico_extra = float(datos.get("critico_extra", 0.0))
	bloque.dano_critico_extra = float(datos.get("dano_critico_extra", 0.0))
	bloque.celeridad_extra = float(datos.get("celeridad_extra", 0.0))
	bloque.tenacidad_extra = float(datos.get("tenacidad_extra", 0.0))
	bloque.penetracion_extra = float(datos.get("penetracion_extra", 0.0))
	bloque.velocidad_extra = float(datos.get("velocidad_extra", 0.0))
	bloque.defensa_extra = float(datos.get("defensa_extra", 0.0))
	return bloque


func a_diccionario() -> Dictionary:
	return {
		"nivel": nivel,
		"vigor": vigor,
		"poder": poder,
		"resonancia": resonancia,
		"agilidad": agilidad,
		"critico_extra": critico_extra,
		"dano_critico_extra": dano_critico_extra,
		"celeridad_extra": celeridad_extra,
		"tenacidad_extra": tenacidad_extra,
		"penetracion_extra": penetracion_extra,
		"velocidad_extra": velocidad_extra,
		"defensa_extra": defensa_extra,
	}


## Vida base por nivel: 120 + 26×(n−1) + 0,09×(n−1)².
func vida_base() -> float:
	var n := float(nivel - 1)
	return 120.0 + 26.0 * n + 0.09 * n * n


## Vida con atributos: +8 por punto de Vigor.
func vida_max() -> int:
	return int(round(vida_base() + VIDA_POR_VIGOR * float(vigor)))


## Poder base por nivel: 10 + 1,9×(n−1) + 0,006×(n−1)².
func pod_base() -> float:
	var n := float(nivel - 1)
	return 10.0 + 1.9 * n + 0.006 * n * n


## Poder con atributos: +1 por punto de Poder.
func pod_total() -> float:
	return pod_base() + POD_POR_PUNTO * float(poder)


## Defensa base por nivel: 15 + 2,4×(n−1) + 0,01×(n−1)².
func def_base() -> float:
	var n := float(nivel - 1)
	return 15.0 + 2.4 * n + 0.01 * n * n


## Defensa con atributos: +2 por punto de Vigor por encima del umbral 20.
func def_total() -> float:
	return def_base() + DEF_POR_VIGOR * float(maxi(0, vigor - VIGOR_UMBRAL_DEF)) + maxf(0.0, defensa_extra)


func reserva_max() -> int:
	return RESERVA_BASE + 2 * resonancia


func regeneracion_combate() -> float:
	return REGEN_COMBATE_BASE + 0.05 * float(resonancia)


func regeneracion_fuera_combate() -> float:
	return REGEN_FUERA_COMBATE


## Probabilidad de crítico limitada al 50 %.
func critico() -> float:
	return clampf(CRITICO_BASE + critico_extra, 0.0, CAP_CRITICO)


## Multiplicador de daño crítico limitado al 250 %.
func multiplicador_critico() -> float:
	return clampf(MULTIPLICADOR_CRITICO_BASE + dano_critico_extra, 1.0, CAP_MULTIPLICADOR_CRITICO)


## Celeridad (reducción de cooldown) limitada al 40 %.
func celeridad() -> float:
	return clampf(CELERIDAD_POR_AGILIDAD * float(agilidad) + celeridad_extra, 0.0, CAP_CELERIDAD)


## Tenacidad (reducción de control) limitada al 50 %.
func tenacidad() -> float:
	return clampf(tenacidad_extra, 0.0, CAP_TENACIDAD)


## Penetración limitada al 35 %.
func penetracion() -> float:
	return clampf(PENETRACION_POR_RESONANCIA * float(resonancia) + penetracion_extra, 0.0, CAP_PENETRACION)


## Velocidad en casillas por segundo, con desvío máximo de ±30 %.
func velocidad_casillas() -> float:
	var desvio := clampf(
		VELOCIDAD_POR_AGILIDAD * float(agilidad) + velocidad_extra,
		-CAP_VELOCIDAD,
		CAP_VELOCIDAD
	)
	return VELOCIDAD_BASE * (1.0 + desvio)


## Validación de datos de entrada. Devuelve una lista de problemas (vacía si todo está bien).
func validar() -> Array[String]:
	var problemas: Array[String] = []
	if nivel < NIVEL_MINIMO or nivel > NIVEL_MAXIMO:
		problemas.append("nivel fuera de rango: %d" % nivel)
	for campo in [["vigor", vigor], ["poder", poder], ["resonancia", resonancia], ["agilidad", agilidad]]:
		if int(campo[1]) < 0:
			problemas.append("%s no puede ser negativo" % campo[0])
	return problemas
