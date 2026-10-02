extends SceneTree

## Genera los recursos `src/data/mobs/*.tres` de T1 (5 criaturas: joven + adulto).
## Los patrones de IA se limitan a los TRES implementados en TASK-004
## (pasivo, agresivo, patrulla); el resto llega en TASK-004.1.
## Uso: godot --headless --path . --script tools/generate_mob_resources.gd

const DESTINO := "res://src/data/mobs/%s.tres"
const CARPETA := "res://src/data/mobs"


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(CARPETA)
	var creados := 0
	for definicion in _definiciones():
		var recurso := MobDefinition.new()
		recurso.id = definicion["id"]
		recurso.nombre = definicion["nombre"]
		recurso.familia = definicion["familia"]
		recurso.variante = definicion["variante"]
		recurso.nivel = definicion["nivel"]
		recurso.tipo_dano = definicion.get("tipo_dano", "fisico")
		recurso.vida_base = definicion["vida_base"]
		recurso.defensa_base = definicion["defensa_base"]
		recurso.velocidad = definicion["velocidad"]
		recurso.patron_ia = definicion["patron_ia"]
		recurso.radio_deteccion = definicion.get("radio_deteccion", 6.0)
		recurso.radio_agarre = definicion.get("radio_agarre", 12.0)
		recurso.radio_ataque = definicion.get("radio_ataque", 1.6)
		recurso.tipo_mob = definicion.get("tipo_mob", "comun")
		recurso.contribucion_minima = definicion.get("contribucion_minima", 0.10)
		recurso.coef_ataque = definicion.get("coef_ataque", 0.9)
		recurso.cooldown_ataque = definicion.get("cooldown_ataque", 1.4)
		recurso.botin.assign(definicion.get("botin", []))
		recurso.color_placeholder = definicion.get("color", Color(0.63, 0.36, 0.30, 1.0))
		recurso.escala = definicion.get("escala", 1.0)
		var ruta := DESTINO % recurso.id
		var error := ResourceSaver.save(recurso, ruta)
		if error != OK:
			push_error("No se pudo guardar %s (error %d)" % [ruta, error])
			quit(1)
			return
		creados += 1
		print("OK: %s" % ruta)
	print("MOB_RESOURCES: %d recursos generados" % creados)
	quit(0)


func _definiciones() -> Array:
	var botin_mordeluz := [
		{"item_id": &"fibra", "probabilidad": 0.65, "cantidad_min": 1, "cantidad_max": 3},
		{"item_id": &"cuero", "probabilidad": 0.30, "cantidad_min": 1, "cantidad_max": 2},
	]
	var botin_cuervo := [
		{"item_id": &"fibra", "probabilidad": 0.45, "cantidad_min": 1, "cantidad_max": 2},
		{"item_id": &"pan_brasa", "probabilidad": 0.20, "cantidad_min": 1, "cantidad_max": 1},
	]
	var botin_enredadera := [
		{"item_id": &"hierbas", "probabilidad": 0.55, "cantidad_min": 1, "cantidad_max": 3},
		{"item_id": &"te_hierbas", "probabilidad": 0.20, "cantidad_min": 1, "cantidad_max": 1},
	]
	return [
		{
			"id": &"mordeluz_joven", "nombre": "Mordeluz joven", "familia": &"mordeluz",
			"variante": "joven", "nivel": 3, "vida_base": 26.0, "defensa_base": 4.0,
			"velocidad": 3.2, "patron_ia": "pasivo", "botin": botin_mordeluz,
			"color": Color(0.55, 0.32, 0.28, 1.0), "escala": 0.9,
		},
		{
			"id": &"mordeluz_adulto", "nombre": "Mordeluz adulto", "familia": &"mordeluz",
			"variante": "adulto", "nivel": 6, "vida_base": 26.0, "defensa_base": 4.0,
			"velocidad": 3.6, "patron_ia": "agresivo", "botin": botin_mordeluz,
			"color": Color(0.62, 0.33, 0.26, 1.0), "escala": 1.1,
		},
		{
			"id": &"cuervo_campana_joven", "nombre": "Cuervo de campana joven",
			"familia": &"cuervo_campana", "variante": "joven", "nivel": 5,
			"vida_base": 22.0, "defensa_base": 3.0, "velocidad": 4.2,
			"patron_ia": "patrulla", "botin": botin_cuervo,
			"color": Color(0.24, 0.27, 0.34, 1.0), "escala": 0.85,
		},
		{
			"id": &"cuervo_campana_adulto", "nombre": "Cuervo de campana adulto",
			"familia": &"cuervo_campana", "variante": "adulto", "nivel": 9,
			"vida_base": 22.0, "defensa_base": 3.0, "velocidad": 4.6,
			"patron_ia": "agresivo", "botin": botin_cuervo,
			"color": Color(0.20, 0.24, 0.32, 1.0), "escala": 1.05,
		},
		{
			"id": &"enredadera_emboscada", "nombre": "Enredadera emboscada",
			"familia": &"enredadera", "variante": "joven", "nivel": 10,
			"tipo_dano": "resonante", "vida_base": 40.0, "defensa_base": 10.0,
			"velocidad": 1.0, "patron_ia": "pasivo", "botin": botin_enredadera,
			"radio_deteccion": 3.5, "radio_agarre": 4.0, "radio_ataque": 2.2,
			"coef_ataque": 1.1, "color": Color(0.38, 0.52, 0.28, 1.0), "escala": 1.2,
		},
	]
