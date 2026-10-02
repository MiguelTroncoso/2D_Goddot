class_name EnemyArchetype
extends RefCounted

## Arquetipo de criatura (docs/design/04-world.md §5 y 03-combat.md §9.1).
##
## Solo datos: familia, variante, nivel, estadísticas base, patrón de IA y radios.
## Las variantes multiplican la base común del tramo, de modo que 16 familias
## cubren 64 criaturas sin duplicar fichas de datos.
## Capa: domain/ (lógica pura).

const VARIANTES := {
	&"joven": {"vida": 1.0, "dano": 1.0, "habilidades": 0, "inmune_control": false, "tipo_forzado": &"", "olvido": false},
	&"adulto": {"vida": 1.6, "dano": 1.3, "habilidades": 0, "inmune_control": false, "tipo_forzado": &"", "olvido": false},
	&"ancestral": {"vida": 2.6, "dano": 1.7, "habilidades": 1, "inmune_control": false, "tipo_forzado": &"", "olvido": false},
	&"primigenio": {"vida": 4.0, "dano": 2.2, "habilidades": 2, "inmune_control": true, "tipo_forzado": &"", "olvido": false},
	&"umbrio": {"vida": 1.0, "dano": 1.25, "habilidades": 0, "inmune_control": false, "tipo_forzado": DamageTypes.UMBRIO, "olvido": true},
	&"elite": {"vida": 3.2, "dano": 1.8, "habilidades": 1, "inmune_control": false, "tipo_forzado": &"", "olvido": false},
}

## Patrones de IA válidos (03-combat.md §9.2).
const PATRONES_IA := [
	&"pasivo", &"errante", &"patrulla", &"territorial", &"agresivo",
	&"manada", &"emboscada", &"guardian", &"jefe",
]

const TIPOS_MOB := [&"comun", &"elite", &"minijefe", &"jefe_tramo", &"jefe_instancia", &"jefe_raid", &"jefe_mundial"]

var id: StringName = &""
var nombre: String = ""
var familia: StringName = &""
var variante: StringName = &"joven"
var nivel: int = 1
var tipo_dano: StringName = DamageTypes.FISICO
var vida_base: float = 1.0
var defensa_base: float = 0.0
var velocidad: float = 3.0
var patron_ia: StringName = &"errante"
var radio_deteccion: float = 5.0
var radio_agarre: float = 10.0
var radio_ataque: float = 1.5
var tipo_mob: StringName = &"comun"
var contribucion_minima: float = 0.10


## Crea un arquetipo desde un diccionario (futuro `data/enemies/*.tres`).
static func crear(datos: Dictionary) -> EnemyArchetype:
	var arquetipo := EnemyArchetype.new()
	arquetipo.id = datos.get("id", &"")
	arquetipo.nombre = String(datos.get("nombre", ""))
	arquetipo.familia = datos.get("familia", &"")
	arquetipo.variante = datos.get("variante", &"joven")
	arquetipo.nivel = int(datos.get("nivel", 1))
	arquetipo.vida_base = float(datos.get("vida_base", 1.0))
	arquetipo.defensa_base = float(datos.get("defensa_base", 0.0))
	arquetipo.velocidad = float(datos.get("velocidad", 3.0))
	arquetipo.patron_ia = datos.get("patron_ia", &"errante")
	arquetipo.radio_deteccion = float(datos.get("radio_deteccion", 5.0))
	arquetipo.radio_agarre = float(datos.get("radio_agarre", 10.0))
	arquetipo.radio_ataque = float(datos.get("radio_ataque", 1.5))
	arquetipo.tipo_mob = datos.get("tipo_mob", &"comun")
	arquetipo.contribucion_minima = float(datos.get("contribucion_minima", 0.10))
	var tipo_declarado: StringName = datos.get("tipo_dano", &"")
	arquetipo.tipo_dano = arquetipo._tipo_final(tipo_declarado)
	return arquetipo


func a_diccionario() -> Dictionary:
	return {
		"id": id,
		"nombre": nombre,
		"familia": familia,
		"variante": variante,
		"nivel": nivel,
		"tipo_dano": tipo_dano,
		"vida_base": vida_base,
		"defensa_base": defensa_base,
		"velocidad": velocidad,
		"patron_ia": patron_ia,
		"radio_deteccion": radio_deteccion,
		"radio_agarre": radio_agarre,
		"radio_ataque": radio_ataque,
		"tipo_mob": tipo_mob,
		"contribucion_minima": contribucion_minima,
	}


static func es_variante_valida(variante_id: StringName) -> bool:
	return VARIANTES.has(variante_id)


static func es_patron_valido(patron: StringName) -> bool:
	return PATRONES_IA.has(patron)


static func variantes_disponibles() -> Array:
	return VARIANTES.keys()


func _tipo_final(tipo_declarado: StringName) -> StringName:
	var forzado: StringName = VARIANTES.get(variante, {}).get("tipo_forzado", &"")
	if forzado != &"":
		return forzado
	if DamageTypes.es_valido(tipo_declarado):
		return tipo_declarado
	return DamageTypes.FISICO


## Vida efectiva de la variante sobre la base común del tramo.
func vida() -> float:
	return vida_base * float(VARIANTES.get(variante, {}).get("vida", 1.0))


func multiplicador_dano() -> float:
	return float(VARIANTES.get(variante, {}).get("dano", 1.0))


func habilidades_extra() -> int:
	return int(VARIANTES.get(variante, {}).get("habilidades", 0))


func inmune_control() -> bool:
	return bool(VARIANTES.get(variante, {}).get("inmune_control", false))


## La variante umbría aplica `olvido` (03-combat.md §5.2) además de forzar daño Umbrío.
func aplica_olvido() -> bool:
	return bool(VARIANTES.get(variante, {}).get("olvido", false))


## XP que otorga esta criatura según su tipo de encuentro (06-progression.md §1.3).
func xp() -> int:
	return XpCurve.xp_criatura(nivel, tipo_mob)


## Bloque de estadísticas equivalente para el combate autoritativo.
## La Vida se pasa aparte (`vida_base` × variante) al registrar el actor.
func stat_block() -> StatBlock:
	var bloque := StatBlock.base(nivel)
	bloque.defensa_extra = maxf(0.0, defensa_base - bloque.def_base())
	return bloque


## Validación de datos para el pipeline de `data/`. Lista vacía si el arquetipo es válido.
func validar() -> Array[String]:
	var problemas: Array[String] = []
	if id == &"":
		problemas.append("id vacío")
	if not es_variante_valida(variante):
		problemas.append("variante desconocida: %s" % variante)
	if not es_patron_valido(patron_ia):
		problemas.append("patrón de IA desconocido: %s" % patron_ia)
	if not TIPOS_MOB.has(tipo_mob):
		problemas.append("tipo de mob desconocido: %s" % tipo_mob)
	if nivel < 1 or nivel > 150:
		problemas.append("nivel fuera de rango: %d" % nivel)
	if vida_base <= 0.0:
		problemas.append("vida_base debe ser positiva")
	if defensa_base < 0.0:
		problemas.append("defensa_base no puede ser negativa")
	if velocidad <= 0.0:
		problemas.append("velocidad debe ser positiva")
	if radio_deteccion <= 0.0 or radio_agarre < radio_deteccion:
		problemas.append("radios de IA inconsistentes")
	if radio_ataque <= 0.0:
		problemas.append("radio_ataque debe ser positivo")
	if contribucion_minima < 0.0 or contribucion_minima > 1.0:
		problemas.append("contribucion_minima fuera de rango")
	return problemas
