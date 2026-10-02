@tool
class_name MobDefinition
extends Resource

## Recurso de datos de una criatura (capa `data/`, ADR-005).
##
## No contiene lógica: solo campos editables en el inspector y una conversión
## explícita al arquetipo puro del dominio (`EnemyArchetype`).
## Esquema documentado en `docs/agent/SCHEMAS.md`.

@export var id: StringName = &""
@export var nombre: String = ""
@export var familia: StringName = &""
@export_enum("joven", "adulto", "ancestral", "primigenio", "umbrio", "elite")
var variante: String = "joven"
@export_range(1, 150, 1) var nivel: int = 1
@export_enum("fisico", "resonante", "umbrio") var tipo_dano: String = "fisico"
@export_range(1.0, 100000.0, 1.0) var vida_base: float = 20.0
@export_range(0.0, 100000.0, 1.0) var defensa_base: float = 5.0
@export_range(0.1, 20.0, 0.1) var velocidad: float = 3.0
@export_enum(
	"pasivo", "errante", "patrulla", "territorial", "agresivo", "manada",
	"emboscada", "guardian", "jefe", "huida", "apoyo", "erratico"
) var patron_ia: String = "errante"
@export_range(1.0, 30.0, 0.5) var radio_deteccion: float = 6.0
@export_range(1.0, 40.0, 0.5) var radio_agarre: float = 12.0
@export_range(0.5, 10.0, 0.1) var radio_ataque: float = 1.6
@export_enum(
	"comun", "elite", "minijefe", "jefe_tramo", "jefe_instancia", "jefe_raid", "jefe_mundial"
) var tipo_mob: String = "comun"
@export_range(0.0, 1.0, 0.01) var contribucion_minima: float = 0.10
@export var coef_ataque: float = 0.9
@export_range(0.0, 60.0, 0.1) var cooldown_ataque: float = 1.4
## Cada entrada: {item_id: StringName, probabilidad: float, cantidad_min: int, cantidad_max: int}
@export var botin: Array[Dictionary] = []
@export var color_placeholder: Color = Color(0.63, 0.36, 0.30, 1.0)
@export_range(0.5, 4.0, 0.1) var escala: float = 1.0


## Diccionario con las claves que espera `EnemyArchetype.crear()`.
func a_diccionario() -> Dictionary:
	return {
		"id": id,
		"nombre": nombre,
		"familia": familia,
		"variante": StringName(variante),
		"nivel": nivel,
		"tipo_dano": StringName(tipo_dano),
		"vida_base": vida_base,
		"defensa_base": defensa_base,
		"velocidad": velocidad,
		"patron_ia": StringName(patron_ia),
		"radio_deteccion": radio_deteccion,
		"radio_agarre": radio_agarre,
		"radio_ataque": radio_ataque,
		"tipo_mob": StringName(tipo_mob),
		"contribucion_minima": contribucion_minima,
	}


func arquetipo() -> EnemyArchetype:
	return EnemyArchetype.crear(a_diccionario())


## Validación de datos + validación del arquetipo resultante.
func validar() -> Array[String]:
	var problemas := arquetipo().validar()
	if coef_ataque <= 0.0:
		problemas.append("coef_ataque debe ser positivo")
	if cooldown_ataque <= 0.0:
		problemas.append("cooldown_ataque debe ser positivo")
	if escala <= 0.0:
		problemas.append("escala debe ser positiva")
	for entrada in botin:
		if not entrada.has("item_id") or entrada.get("item_id", &"") == &"":
			problemas.append("entrada de botín sin item_id")
			continue
		var probabilidad := float(entrada.get("probabilidad", 0.0))
		if probabilidad < 0.0 or probabilidad > 1.0:
			problemas.append("probabilidad fuera de rango en %s" % entrada["item_id"])
		if int(entrada.get("cantidad_min", 1)) < 1:
			problemas.append("cantidad_min inválida en %s" % entrada["item_id"])
		if int(entrada.get("cantidad_max", 1)) < int(entrada.get("cantidad_min", 1)):
			problemas.append("cantidad_max menor que cantidad_min en %s" % entrada["item_id"])
	return problemas
