extends GutTest
## Estadísticas y topes — docs/design/02-classes.md §3.1 y 06-progression.md §3.


func test_curvas_base_por_nivel() -> void:
	assert_almost_eq(StatBlock.base(1).vida_base(), 120.0, 0.0001)
	assert_almost_eq(StatBlock.base(15).vida_base(), 501.64, 0.01)
	assert_almost_eq(StatBlock.base(150).vida_base(), 5992.09, 0.01)
	assert_almost_eq(StatBlock.base(1).pod_base(), 10.0, 0.0001)
	assert_almost_eq(StatBlock.base(150).pod_base(), 426.306, 0.01)
	assert_almost_eq(StatBlock.base(1).def_base(), 15.0, 0.0001)
	assert_almost_eq(StatBlock.base(150).def_base(), 594.61, 0.01)


func test_nivel_fuera_de_rango_se_limita() -> void:
	assert_eq(StatBlock.base(0).nivel, 1)
	assert_eq(StatBlock.base(-10).nivel, 1)
	assert_eq(StatBlock.base(900).nivel, StatBlock.NIVEL_MAXIMO)


func test_aportes_de_atributos() -> void:
	var bloque := StatBlock.base(1)
	bloque.vigor = 10
	assert_eq(bloque.vida_max(), 200, "8 de Vida por punto de Vigor")
	bloque.vigor = 20
	assert_almost_eq(bloque.def_total(), 15.0, 0.0001, "el umbral de Vigor para DEF es 20")
	bloque.vigor = 30
	assert_almost_eq(bloque.def_total(), 35.0, 0.0001, "solo los puntos sobre 20 dan DEF")
	bloque.poder = 25
	assert_almost_eq(bloque.pod_total(), 35.0, 0.0001)


func test_reserva_y_regeneracion() -> void:
	var bloque := StatBlock.base(10)
	assert_eq(bloque.reserva_max(), 100, "sin Resonancia la Reserva es 100")
	bloque.resonancia = 150
	assert_eq(bloque.reserva_max(), 400)
	assert_almost_eq(bloque.regeneracion_combate(), 9.5, 0.0001)
	assert_almost_eq(bloque.regeneracion_fuera_combate(), 6.0, 0.0001)


func test_topes_de_estadisticas_secundarias() -> void:
	var bloque := StatBlock.base(150)
	assert_almost_eq(bloque.critico(), 0.05, 0.0001)
	bloque.critico_extra = 0.90
	assert_almost_eq(bloque.critico(), StatBlock.CAP_CRITICO, 0.0001)

	bloque.dano_critico_extra = 5.0
	assert_almost_eq(bloque.multiplicador_critico(), StatBlock.CAP_MULTIPLICADOR_CRITICO, 0.0001)

	bloque.celeridad_extra = 0.0
	bloque.agilidad = 100
	assert_almost_eq(bloque.celeridad(), 0.15, 0.0001)
	bloque.agilidad = 300
	assert_almost_eq(bloque.celeridad(), StatBlock.CAP_CELERIDAD, 0.0001)

	bloque.tenacidad_extra = 0.90
	assert_almost_eq(bloque.tenacidad(), StatBlock.CAP_TENACIDAD, 0.0001)

	bloque.resonancia = 300
	assert_almost_eq(bloque.penetracion(), 0.10, 0.0001)
	bloque.resonancia = 30000
	assert_almost_eq(bloque.penetracion(), StatBlock.CAP_PENETRACION, 0.0001)


func test_velocidad_limitada_a_mas_menos_30_por_ciento() -> void:
	var bloque := StatBlock.base(50)
	assert_almost_eq(bloque.velocidad_casillas(), 4.0, 0.0001)
	bloque.agilidad = 1000
	assert_almost_eq(bloque.velocidad_casillas(), 4.4, 0.0001)
	bloque.agilidad = 100000
	assert_almost_eq(bloque.velocidad_casillas(), 4.0 * 1.30, 0.0001)
	bloque.agilidad = 0
	bloque.velocidad_extra = -5.0
	assert_almost_eq(bloque.velocidad_casillas(), 4.0 * 0.70, 0.0001)


func test_validacion_de_datos() -> void:
	var bloque := StatBlock.base(10)
	assert_eq(bloque.validar().size(), 0, "un bloque limpio no reporta problemas")
	bloque.poder = -1
	assert_eq(bloque.validar().size(), 1)
	assert_true(bloque.validar()[0].contains("poder"))
	bloque.poder = 0
	bloque.nivel = 200
	assert_eq(bloque.validar().size(), 1, "el nivel fuera de rango se detecta al validar")


func test_ida_y_vuelta_por_diccionario() -> void:
	var original := StatBlock.base(42)
	original.vigor = 30
	original.poder = 45
	original.resonancia = 60
	original.agilidad = 15
	original.critico_extra = 0.05
	var reconstruido := StatBlock.desde_diccionario(original.a_diccionario())
	assert_eq(reconstruido.nivel, 42)
	assert_eq(reconstruido.vigor, 30)
	assert_eq(reconstruido.poder, 45)
	assert_eq(reconstruido.resonancia, 60)
	assert_eq(reconstruido.agilidad, 15)
	assert_almost_eq(reconstruido.critico_extra, 0.05, 0.0001)
	assert_eq(reconstruido.vida_max(), original.vida_max())
