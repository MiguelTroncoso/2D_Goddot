@tool
class_name ItemDefinition
extends Resource

## Recurso de datos de un objeto (capa `data/`, ADR-005). Sin lógica.

@export var id: StringName = &""
@export var nombre: String = ""
@export_enum("consumible", "material", "arma", "armadura") var tipo: String = "material"
@export_enum("comun", "fino", "resonante", "raro", "legendario") var rareza: String = "comun"
@export_range(1, 150, 1) var nivel: int = 1
@export_range(0, 1000000, 1) var precio_base: int = 10
@export_range(1, 999, 1) var stack_max: int = 20
@export_multiline var descripcion: String = ""
## Efecto del consumible: {curacion_pct, limpia: Array[StringName], duracion_s, bonus: Dictionary}
@export var efecto: Dictionary = {}


func validar() -> Array[String]:
	var problemas: Array[String] = []
	if id == &"":
		problemas.append("id vacío")
	if nombre == "":
		problemas.append("nombre vacío")
	if nivel < 1 or nivel > 150:
		problemas.append("nivel fuera de rango")
	if precio_base <= 0:
		problemas.append("precio_base debe ser positivo")
	if stack_max < 1:
		problemas.append("stack_max debe ser >= 1")
	if tipo == "consumible" and efecto.is_empty():
		problemas.append("un consumible debe declarar efecto")
	return problemas


func a_diccionario() -> Dictionary:
	return {
		"id": id,
		"nombre": nombre,
		"tipo": StringName(tipo),
		"rareza": StringName(rareza),
		"nivel": nivel,
		"precio_base": precio_base,
		"stack_max": stack_max,
		"descripcion": descripcion,
		"efecto": efecto.duplicate(true),
	}
