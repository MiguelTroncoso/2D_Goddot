extends GutTest
## Arquetipos de criatura y variantes — docs/design/04-world.md §5.

const DATOS_BASE := {
	"id": &"mordeluz_prueba",
	"nombre": "Mordeluz de prueba",
	"familia": &"mordeluz",
	"nivel": 45,
	"vida_base": 100.0,
	"defensa_base": 50.0,
	"velocidad": 3.5,
	"patron_ia": &"manada",
	"tipo_mob": &"jefe_tramo",
}


func test_multiplicadores_por_variante() -> void:
	var joven := EnemyArchetype.crear(DATOS_BASE)
	joven.variante = &"joven"
	assert_almost_eq(joven.vida(), 100.0, 0.0001)
	assert_almost_eq(joven.multiplicador_dano(), 1.0, 0.0001)
	assert_eq(joven.habilidades_extra(), 0)
	assert_false(joven.inmune_control())

	var datos_adulto := DATOS_BASE.duplicate()
	datos_adulto["variante"] = &"adulto"
	var adulto := EnemyArchetype.crear(datos_adulto)
	assert_almost_eq(adulto.vida(), 160.0, 0.0001)
	assert_almost_eq(adulto.multiplicador_dano(), 1.3, 0.0001)

	var datos_ancestral := DATOS_BASE.duplicate()
	datos_ancestral["variante"] = &"ancestral"
	var ancestral := EnemyArchetype.crear(datos_ancestral)
	assert_almost_eq(ancestral.vida(), 260.0, 0.0001)
	assert_eq(ancestral.habilidades_extra(), 1)

	var datos_primigenio := DATOS_BASE.duplicate()
	datos_primigenio["variante"] = &"primigenio"
	var primigenio := EnemyArchetype.crear(datos_primigenio)
	assert_almost_eq(primigenio.vida(), 400.0, 0.0001)
	assert_almost_eq(primigenio.multiplicador_dano(), 2.2, 0.0001)
	assert_eq(primigenio.habilidades_extra(), 2)
	assert_true(primigenio.inmune_control())

	var datos_elite := DATOS_BASE.duplicate()
	datos_elite["variante"] = &"elite"
	var elite := EnemyArchetype.crear(datos_elite)
	assert_almost_eq(elite.vida(), 320.0, 0.0001)
	assert_almost_eq(elite.multiplicador_dano(), 1.8, 0.0001)


func test_variante_umbria_fuerza_tipo_y_olvido() -> void:
	var datos := DATOS_BASE.duplicate()
	datos["variante"] = &"umbrio"
	datos["tipo_dano"] = DamageTypes.FISICO
	var umbrio := EnemyArchetype.crear(datos)
	assert_eq(umbrio.tipo_dano, DamageTypes.UMBRIO, "la variante umbría fuerza daño Umbrío")
	assert_true(umbrio.aplica_olvido())
	assert_almost_eq(umbrio.multiplicador_dano(), 1.25, 0.0001)


func test_tipo_declarado_y_tipo_desconocido() -> void:
	var datos := DATOS_BASE.duplicate()
	datos["variante"] = &"joven"
	datos["tipo_dano"] = DamageTypes.RESONANTE
	assert_eq(EnemyArchetype.crear(datos).tipo_dano, DamageTypes.RESONANTE)
	datos["tipo_dano"] = &"fuego"
	assert_eq(
		EnemyArchetype.crear(datos).tipo_dano,
		DamageTypes.FISICO,
		"un tipo inválido cae al valor por defecto"
	)


func test_variantes_y_patrones_disponibles() -> void:
	assert_eq(EnemyArchetype.variantes_disponibles().size(), 6)
	assert_eq(EnemyArchetype.PATRONES_IA.size(), 9)
	assert_true(EnemyArchetype.es_variante_valida(&"primigenio"))
	assert_false(EnemyArchetype.es_variante_valida(&"inventada"))
	assert_true(EnemyArchetype.es_patron_valido(&"emboscada"))
	assert_false(EnemyArchetype.es_patron_valido(&"bailarin"))


func test_xp_segun_tipo_de_mob() -> void:
	var datos := DATOS_BASE.duplicate()
	datos["variante"] = &"joven"
	var jefe := EnemyArchetype.crear(datos)
	assert_eq(jefe.xp(), XpCurve.xp_criatura(45, &"jefe_tramo"))
	datos["tipo_mob"] = &"comun"
	var comun := EnemyArchetype.crear(datos)
	assert_lt(comun.xp(), jefe.xp())


func test_validacion_detecta_datos_incompletos() -> void:
	var vacio := EnemyArchetype.crear({})
	assert_eq(vacio.validar().size(), 1, "un arquetipo vacío solo reporta el id")
	assert_true(vacio.validar()[0].contains("id"))

	var malo := EnemyArchetype.crear({
		"id": &"roto",
		"variante": &"inventada",
		"patron_ia": &"bailarin",
		"tipo_mob": &"inventado",
		"nivel": 900,
		"vida_base": -5.0,
		"defensa_base": -1.0,
		"velocidad": 0.0,
		"radio_deteccion": 10.0,
		"radio_agarre": 2.0,
		"radio_ataque": 0.0,
		"contribucion_minima": 2.0,
	})
	var problemas := malo.validar()
	assert_gt(problemas.size(), 8, "la validación cubre variante, patrón, tipo, nivel, stats y radios")


func test_ida_y_vuelta_por_diccionario() -> void:
	var datos := DATOS_BASE.duplicate()
	datos["variante"] = &"ancestral"
	var original := EnemyArchetype.crear(datos)
	var reconstruido := EnemyArchetype.crear(original.a_diccionario())
	assert_eq(reconstruido.id, original.id)
	assert_eq(reconstruido.variante, original.variante)
	assert_eq(reconstruido.nivel, original.nivel)
	assert_almost_eq(reconstruido.vida(), original.vida(), 0.0001)
	assert_eq(reconstruido.validar().size(), 0)
