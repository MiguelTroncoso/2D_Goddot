extends GutTest
## Mitigación por tipo — docs/design/03-combat.md §2.2.


func test_constante_k_por_tipo_y_nivel() -> void:
	assert_almost_eq(MitigationResolver.constante_k(10, DamageTypes.FISICO), 150.0, 0.0001)
	assert_almost_eq(MitigationResolver.constante_k(10, DamageTypes.RESONANTE), 225.0, 0.0001)
	assert_almost_eq(MitigationResolver.constante_k(10, DamageTypes.UMBRIO), 225.0, 0.0001)
	assert_almost_eq(MitigationResolver.constante_k(150, DamageTypes.FISICO), 1550.0, 0.0001)
	assert_almost_eq(
		MitigationResolver.constante_k(0, DamageTypes.FISICO),
		60.0,
		0.0001,
		"nivel 0 se limita a 1"
	)


func test_mitigacion_sigue_la_curva() -> void:
	assert_almost_eq(MitigationResolver.mitigacion(80.0, 10, DamageTypes.FISICO), 8.0 / 23.0, 0.0001)
	assert_almost_eq(MitigationResolver.mitigacion(225.0, 10, DamageTypes.UMBRIO), 0.5, 0.0001)
	assert_almost_eq(MitigationResolver.mitigacion(100.0, 1, DamageTypes.FISICO), 100.0 / 160.0, 0.0001)


func test_mitigacion_en_los_bordes() -> void:
	assert_almost_eq(MitigationResolver.mitigacion(0.0, 10, DamageTypes.FISICO), 0.0, 0.0001)
	assert_almost_eq(MitigationResolver.mitigacion(-50.0, 10, DamageTypes.FISICO), 0.0, 0.0001, "defensa negativa no mitiga")
	assert_almost_eq(
		MitigationResolver.mitigacion(1000000.0, 10, DamageTypes.FISICO),
		MitigationResolver.CAP_MITIGACION,
		0.0001,
		"nadie es inmune: tope del 75 %"
	)


func test_defensa_efectiva_con_penetracion() -> void:
	assert_almost_eq(MitigationResolver.defensa_efectiva(100.0, 0.0), 100.0, 0.0001)
	assert_almost_eq(MitigationResolver.defensa_efectiva(100.0, 0.35), 65.0, 0.0001)
	assert_almost_eq(
		MitigationResolver.defensa_efectiva(100.0, 0.90),
		65.0,
		0.0001,
		"la penetración tiene tope del 35 %"
	)
	assert_almost_eq(MitigationResolver.defensa_efectiva(-10.0, 0.5), 0.0, 0.0001)


func test_aplicar_dano_y_desglose() -> void:
	var esperado := 100.0 * (1.0 - 8.0 / 23.0)
	assert_almost_eq(MitigationResolver.aplicar(100.0, 80.0, 10, DamageTypes.FISICO), esperado, 0.0001)
	var desglose := MitigationResolver.desglosar(100.0, 80.0, 10, DamageTypes.FISICO)
	assert_almost_eq(float(desglose["mitigacion"]), 8.0 / 23.0, 0.0001)
	assert_almost_eq(float(desglose["dano_tras_mitigar"]), esperado, 0.0001)
	assert_almost_eq(float(desglose["k"]), 150.0, 0.0001)
	assert_eq(desglose["tipo"], DamageTypes.FISICO)


func test_penetracion_reduce_la_mitigacion() -> void:
	var sin_penetracion := MitigationResolver.mitigacion(100.0, 10, DamageTypes.FISICO)
	var con_penetracion := MitigationResolver.mitigacion(
		MitigationResolver.defensa_efectiva(100.0, 0.35),
		10,
		DamageTypes.FISICO
	)
	assert_lt(con_penetracion, sin_penetracion, "penetrar debe bajar la mitigación efectiva")
