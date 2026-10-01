extends GutTest
## Críticos deterministas — docs/design/03-combat.md §2.3.


func test_probabilidad_base_y_tope() -> void:
	assert_almost_eq(CritRoller.probabilidad(), 0.05, 0.0001)
	assert_almost_eq(CritRoller.probabilidad(0.05, 0.10, 0.05), 0.20, 0.0001)
	assert_almost_eq(CritRoller.probabilidad(0.40, 0.30, 0.00), 0.50, 0.0001, "tope del 50 %")
	assert_almost_eq(CritRoller.probabilidad(0.0, 0.0, 0.0), 0.0, 0.0001)
	assert_almost_eq(CritRoller.probabilidad(-1.0), 0.0, 0.0001, "no hay probabilidad negativa")


func test_multiplicador_base_y_tope() -> void:
	assert_almost_eq(CritRoller.multiplicador(), 1.50, 0.0001)
	assert_almost_eq(CritRoller.multiplicador(0.50), 2.00, 0.0001)
	assert_almost_eq(CritRoller.multiplicador(5.0), 2.50, 0.0001, "tope del 250 %")
	assert_almost_eq(CritRoller.multiplicador(-2.0), 1.0, 0.0001)


func test_resolucion_determinista_de_la_tirada() -> void:
	var acierto := CritRoller.resolver(0.50, 2.50, 0.499)
	assert_true(bool(acierto["es_critico"]))
	assert_almost_eq(float(acierto["multiplicador"]), 2.50, 0.0001)

	var fallo := CritRoller.resolver(0.50, 2.50, 0.50)
	assert_false(bool(fallo["es_critico"]), "la tirada igual a la probabilidad no es crítica")
	assert_almost_eq(float(fallo["multiplicador"]), 1.0, 0.0001)

	var imposible := CritRoller.resolver(0.0, 1.50, 0.0)
	assert_false(bool(imposible["es_critico"]), "con probabilidad 0 nunca hay crítico")


func test_atajo_tirar_y_aplicar() -> void:
	var resultado := CritRoller.tirar(0.05, 0.10, 0.0, 0.0, 0.10)
	assert_true(bool(resultado["es_critico"]))
	assert_almost_eq(CritRoller.aplicar(100.0, resultado), 150.0, 0.0001)
	assert_almost_eq(CritRoller.aplicar(100.0, {"multiplicador": 2.0}), 200.0, 0.0001)
	assert_almost_eq(
		CritRoller.aplicar(100.0, {}),
		100.0,
		0.0001,
		"un resultado vacío no modifica el daño"
	)
