extends SceneTree

## Genera los recursos `src/data/items/*.tres` de T1 (5 consumibles + 3 materiales).
## Uso: godot --headless --path . --script tools/generate_item_resources.gd

const DESTINO := "res://src/data/items/%s.tres"
const CARPETA := "res://src/data/items"


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(CARPETA)
	var creados := 0
	for definicion in _definiciones():
		var recurso := ItemDefinition.new()
		recurso.id = definicion["id"]
		recurso.nombre = definicion["nombre"]
		recurso.tipo = definicion.get("tipo", "material")
		recurso.rareza = definicion.get("rareza", "comun")
		recurso.nivel = definicion.get("nivel", 1)
		recurso.precio_base = definicion.get("precio_base", 10)
		recurso.stack_max = definicion.get("stack_max", 20)
		recurso.descripcion = definicion.get("descripcion", "")
		recurso.efecto = definicion.get("efecto", {})
		var ruta := DESTINO % recurso.id
		var error := ResourceSaver.save(recurso, ruta)
		if error != OK:
			push_error("No se pudo guardar %s (error %d)" % [ruta, error])
			quit(1)
			return
		creados += 1
		print("OK: %s" % ruta)
	print("ITEM_RESOURCES: %d recursos generados" % creados)
	quit(0)


func _definiciones() -> Array:
	return [
		{
			"id": &"pan_brasa", "nombre": "Pan de brasa", "tipo": "consumible",
			"precio_base": 25, "stack_max": 20,
			"descripcion": "Cura 15 % de la Vida máxima, solo fuera de combate.",
			"efecto": {"curacion_pct": 0.15, "fuera_de_combate": true},
		},
		{
			"id": &"te_hierbas", "nombre": "Té de hierbas amargas", "tipo": "consumible",
			"precio_base": 30, "stack_max": 20,
			"descripcion": "Limpia quemadura y zumbido.",
			"efecto": {"limpia": [&"quemadura", &"zumbido"], "cooldown_s": 20.0},
		},
		{
			"id": &"pocion_savia_menor", "nombre": "Poción de savia menor", "tipo": "consumible",
			"precio_base": 40, "stack_max": 20,
			"descripcion": "Cura 30 % de la Vida máxima.",
			"efecto": {"curacion_pct": 0.30, "cooldown_s": 30.0},
		},
		{
			"id": &"piedra_retorno", "nombre": "Piedra de retorno", "tipo": "consumible",
			"rareza": "fino", "precio_base": 60, "stack_max": 5,
			"descripcion": "Vuelve al último waypoint encendido.",
			"efecto": {"teleporte": true, "cooldown_s": 600.0},
		},
		{
			"id": &"elixir_lumbre", "nombre": "Elixir de lumbre", "tipo": "consumible",
			"rareza": "resonante", "nivel": 5, "precio_base": 120, "stack_max": 10,
			"descripcion": "+10 % de daño y +5 % de curación durante 20 minutos.",
			"efecto": {"bonus": {"dano_pct": 0.10, "curacion_pct": 0.05}, "duracion_s": 1200.0},
		},
		{
			"id": &"fibra", "nombre": "Fibra", "tipo": "material", "precio_base": 4, "stack_max": 99,
			"descripcion": "Material textil básico del Prado de Senda.",
		},
		{
			"id": &"cuero", "nombre": "Cuero", "tipo": "material", "precio_base": 6, "stack_max": 99,
			"descripcion": "Piel curtida de fauna de la cuenca.",
		},
		{
			"id": &"hierbas", "nombre": "Hierbas", "tipo": "material", "precio_base": 5, "stack_max": 99,
			"descripcion": "Hierbas de terraza, base de pociones y té.",
		},
	]
