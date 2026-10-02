class_name LootSystem
extends RefCounted

## Botín, Cobre y XP por criatura (docs/design/05-economy.md §4 y 06-progression.md §1.3).
##
## Las tablas de botín llegan desde `data/mobs/*.tres`; las de familia aquí son el
## respaldo mínimo de T1 cuando un recurso no declara tabla propia.
## Capa: systems/ (usa domain/, no toca ui/, net/ ni entities/).

signal botin_generado(evento: Dictionary)

const TIRADAS_POR_VARIANTE := {
	&"joven": 1,
	&"adulto": 1,
	&"ancestral": 2,
	&"primigenio": 2,
	&"umbrio": 1,
	&"elite": 2,
}

## Respaldo de T1 si el recurso de datos no trae tabla (docs/design/04-world.md §4 T1).
const TABLAS_POR_FAMILIA := {
	&"mordeluz": [
		{"item_id": &"fibra", "probabilidad": 0.65, "cantidad_min": 1, "cantidad_max": 3},
		{"item_id": &"cuero", "probabilidad": 0.30, "cantidad_min": 1, "cantidad_max": 2},
	],
	&"cuervo_campana": [
		{"item_id": &"fibra", "probabilidad": 0.45, "cantidad_min": 1, "cantidad_max": 2},
		{"item_id": &"pan_brasa", "probabilidad": 0.20, "cantidad_min": 1, "cantidad_max": 1},
	],
	&"reptil_raiz": [
		{"item_id": &"cuero", "probabilidad": 0.50, "cantidad_min": 1, "cantidad_max": 2},
		{"item_id": &"hierbas", "probabilidad": 0.40, "cantidad_min": 1, "cantidad_max": 2},
	],
	&"enredadera": [
		{"item_id": &"hierbas", "probabilidad": 0.55, "cantidad_min": 1, "cantidad_max": 3},
		{"item_id": &"te_hierbas", "probabilidad": 0.20, "cantidad_min": 1, "cantidad_max": 1},
	],
	&"nido_chispas": [
		{"item_id": &"pocion_savia_menor", "probabilidad": 0.15, "cantidad_min": 1, "cantidad_max": 1},
		{"item_id": &"elixir_lumbre", "probabilidad": 0.05, "cantidad_min": 1, "cantidad_max": 1},
	],
}

const TABLA_VACIA: Array = []

var _rng := RandomNumberGenerator.new()
var _botines: int = 0


func _init(semilla: int = 0) -> void:
	if semilla == 0:
		_rng.randomize()
	else:
		_rng.seed = semilla


func botines_generados() -> int:
	return _botines


## Tabla efectiva: la del recurso si existe, si no la de respaldo por familia.
func tabla_para(arquetipo: EnemyArchetype, tabla_declarada: Array = []) -> Array:
	if tabla_declarada.size() > 0:
		return tabla_declarada
	return TABLAS_POR_FAMILIA.get(arquetipo.familia, TABLA_VACIA)


## Genera el botín de una criatura. Repite la tirada según la variante (élites y
## ancestrales tiran dos veces) y respeta cantidades mínimas y máximas.
func generar_botin(arquetipo: EnemyArchetype, tabla_declarada: Array = []) -> Array:
	var tabla := tabla_para(arquetipo, tabla_declarada)
	var tiradas := int(TIRADAS_POR_VARIANTE.get(arquetipo.variante, 1))
	var resultado: Array = []
	for _tirada in range(tiradas):
		for entrada in tabla:
			if _rng.randf() > float(entrada.get("probabilidad", 0.0)):
				continue
			var minimo := int(entrada.get("cantidad_min", 1))
			var maximo := maxi(minimo, int(entrada.get("cantidad_max", minimo)))
			var cantidad := _rng.randi_range(minimo, maximo)
			_acumular(resultado, entrada.get("item_id", &""), cantidad)
	_botines += 1
	botin_generado.emit({"arquetipo": arquetipo.id, "items": resultado, "tiradas": tiradas})
	return resultado


## XP que otorga la criatura a un jugador de nivel dado (curva canónica).
func otorgar_xp(arquetipo: EnemyArchetype, nivel_jugador: int) -> Dictionary:
	return {
		"xp": XpCurve.xp_ajustada(arquetipo.nivel, nivel_jugador, arquetipo.tipo_mob),
		"tipo": arquetipo.tipo_mob,
		"nivel_criatura": arquetipo.nivel,
		"nivel_jugador": XpCurve.nivel_limitado(nivel_jugador),
		"arquetipo": arquetipo.id,
	}


## Cobre que suelta la criatura según tramo y tipo.
func generar_cobre(arquetipo: EnemyArchetype) -> int:
	return CoinTables.calcular(arquetipo.nivel, arquetipo.tipo_mob, _rng.randf())


func _acumular(destino: Array, item_id: StringName, cantidad: int) -> void:
	if item_id == &"" or cantidad <= 0:
		return
	for entrada in destino:
		if entrada["item_id"] == item_id:
			entrada["cantidad"] += cantidad
			return
	destino.append({"item_id": item_id, "cantidad": cantidad})
