extends GutTest
## Botín, cobre y XP: casos borde (TASK-004).

const TABLA_GARANTIZADA := [
	{"item_id": &"fibra", "probabilidad": 1.0, "cantidad_min": 2, "cantidad_max": 2},
]
const TABLA_IMPOSIBLE := [
	{"item_id": &"cuero", "probabilidad": 0.0, "cantidad_min": 1, "cantidad_max": 5},
]


func _arquetipo(variante: StringName = &"joven", familia: StringName = &"mordeluz") -> EnemyArchetype:
	return EnemyArchetype.crear({
		"id": &"prueba",
		"nombre": "Criatura de prueba",
		"familia": familia,
		"variante": variante,
		"nivel": 10,
		"vida_base": 100.0,
		"defensa_base": 10.0,
		"velocidad": 3.0,
		"patron_ia": &"pasivo",
		"tipo_mob": &"comun",
	})


func test_drop_garantizado() -> void:
	var loot := LootSystem.new(5)
	var resultado := loot.generar_botin(_arquetipo(), TABLA_GARANTIZADA)
	assert_eq(resultado.size(), 1, "probabilidad 1.0 siempre suelta")
	assert_eq(resultado[0]["item_id"], &"fibra")
	assert_eq(int(resultado[0]["cantidad"]), 2)
	assert_eq(loot.botines_generados(), 1)


func test_drop_imposible() -> void:
	var loot := LootSystem.new(5)
	var resultado := loot.generar_botin(_arquetipo(), TABLA_IMPOSIBLE)
	assert_eq(resultado.size(), 0, "probabilidad 0.0 nunca suelta")
	assert_eq(loot.botines_generados(), 1, "la tirada se cuenta aunque no caiga nada")


func test_rng_determinista_con_semilla_fija() -> void:
	var primero := LootSystem.new(1234)
	var segundo := LootSystem.new(1234)
	var tabla := LootSystem.TABLAS_POR_FAMILIA[&"cuervo_campana"]
	for indice in range(5):
		assert_eq(
			primero.generar_botin(_arquetipo(&"adulto", &"cuervo_campana"), tabla),
			segundo.generar_botin(_arquetipo(&"adulto", &"cuervo_campana"), tabla),
			"la tirada %d debe repetirse con la misma semilla" % indice
		)


func test_tabla_declarada_tiene_prioridad_y_familia_desconocida_es_vacia() -> void:
	var loot := LootSystem.new(9)
	assert_eq(loot.tabla_para(_arquetipo(), TABLA_GARANTIZADA), TABLA_GARANTIZADA)
	assert_eq(
		loot.tabla_para(_arquetipo(&"joven", &"familia_inexistente")),
		LootSystem.TABLA_VACIA
	)
	assert_eq(loot.generar_botin(_arquetipo(&"joven", &"familia_inexistente")).size(), 0)


func test_variantes_con_mas_tiradas_dropean_mas() -> void:
	var tabla := TABLA_GARANTIZADA
	var joven := LootSystem.new(3).generar_botin(_arquetipo(&"joven"), tabla)
	var elite := LootSystem.new(3).generar_botin(_arquetipo(&"elite"), tabla)
	assert_eq(int(joven[0]["cantidad"]), 2)
	assert_eq(int(elite[0]["cantidad"]), 4, "la variante élite repite la tabla dos veces")


func test_los_drops_se_acumulan_por_item() -> void:
	var tabla := [
		{"item_id": &"fibra", "probabilidad": 1.0, "cantidad_min": 1, "cantidad_max": 1},
		{"item_id": &"fibra", "probabilidad": 1.0, "cantidad_min": 2, "cantidad_max": 2},
	]
	var resultado := LootSystem.new(1).generar_botin(_arquetipo(), tabla)
	assert_eq(resultado.size(), 1, "el mismo material no ocupa dos entradas")
	assert_eq(int(resultado[0]["cantidad"]), 3)


func test_xp_por_tipo_de_mob_usa_la_curva_canonica() -> void:
	var loot := LootSystem.new(1)
	var comun := _arquetipo()
	var recompensa := loot.otorgar_xp(comun, 10)
	assert_eq(int(recompensa["xp"]), XpCurve.xp_ajustada(10, 10, &"comun"))
	assert_eq(recompensa["tipo"], &"comun")
	assert_eq(int(recompensa["nivel_jugador"]), 10)

	var jefe := EnemyArchetype.crear({
		"id": &"jefe", "familia": &"mordeluz", "variante": &"elite", "nivel": 50,
		"vida_base": 100.0, "defensa_base": 10.0, "velocidad": 3.0,
		"patron_ia": &"pasivo", "tipo_mob": &"jefe_tramo",
	})
	assert_gt(loot.otorgar_xp(jefe, 10)["xp"], recompensa["xp"], "un jefe da más XP que un común")
	assert_eq(
		int(loot.otorgar_xp(comun, 999)["xp"]),
		0,
		"sin diferencia de nivel real no hay recompensa por debajo del umbral"
	)


func test_cobre_dentro_del_rango_del_tramo() -> void:
	var loot := LootSystem.new(4)
	var arquetipo := _arquetipo()
	var rango := CoinTables.rango_para_nivel(arquetipo.nivel)
	var maximo := CoinTables.maximo(arquetipo.nivel, arquetipo.tipo_mob)
	for _intento in range(20):
		var cobre := loot.generar_cobre(arquetipo)
		assert_between(cobre, int(rango[0]), maximo)
	assert_eq(CoinTables.tramo_de_nivel(10), 1)
	assert_eq(CoinTables.rango_por_tramo(1), CoinTables.RANGOS_POR_TRAMO[0])
	assert_almost_eq(CoinTables.multiplicador_tipo(&"comun"), 1.0, 0.0001)
	assert_almost_eq(CoinTables.multiplicador_tipo(&"inventado"), 1.0, 0.0001)
	assert_eq(CoinTables.calcular(10, &"comun", 0.0), int(rango[0]), "tirada 0 da el mínimo")
	assert_eq(CoinTables.calcular(10, &"comun", 1.0), int(rango[1]), "tirada 1 da el máximo")
