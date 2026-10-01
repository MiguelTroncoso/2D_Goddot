extends GutTest
## Fórmula canónica de daño — docs/design/03-combat.md §2 y §2.5.


func test_tramos_de_plano() -> void:
	assert_eq(DamageCalculator.tramo_de_nivel(1), 1)
	assert_eq(DamageCalculator.tramo_de_nivel(15), 1)
	assert_eq(DamageCalculator.tramo_de_nivel(16), 2)
	assert_eq(DamageCalculator.tramo_de_nivel(150), 10)
	assert_eq(DamageCalculator.tramo_de_nivel(0), 1, "borde inferior limitado")
	assert_eq(DamageCalculator.tramo_de_nivel(999), 10, "borde superior limitado")


func test_nivel_limitado_y_tabla_de_plano() -> void:
	assert_eq(DamageCalculator.nivel_limitado(-5), 1)
	assert_eq(DamageCalculator.nivel_limitado(75), 75)
	assert_eq(DamageCalculator.nivel_limitado(400), DamageCalculator.NIVEL_MAXIMO)
	var entrada := DamageCalculator.tabla_plano(1)
	assert_almost_eq(float(entrada["base"]), 6.0, 0.0001)
	assert_eq(int(entrada["tramo"]), 1)
	var ultima := DamageCalculator.tabla_plano(150)
	assert_eq(int(ultima["tramo"]), 10, "el nivel máximo usa la última entrada de la tabla")


func test_plano_por_tramo_arranca_donde_termina_el_anterior() -> void:
	assert_almost_eq(DamageCalculator.plano_habilidad(1, 1.0), 6.0, 0.0001)
	assert_almost_eq(DamageCalculator.plano_habilidad(15, 1.0), 27.0, 0.0001)
	assert_almost_eq(DamageCalculator.plano_habilidad(16, 1.0), 29.6, 0.0001)
	assert_almost_eq(DamageCalculator.plano_habilidad(30, 1.0), 66.0, 0.0001)
	assert_almost_eq(DamageCalculator.plano_habilidad(150, 1.0), 4715.0, 0.0001)
	assert_almost_eq(DamageCalculator.plano_habilidad(150, 2.0), 9430.0, 0.0001)


func test_factor_de_nivel() -> void:
	assert_almost_eq(DamageCalculator.factor_nivel(1), 1.0, 0.0001)
	assert_almost_eq(DamageCalculator.factor_nivel(10), 1.18, 0.0001)
	assert_almost_eq(DamageCalculator.factor_nivel(150), 3.98, 0.0001)
	assert_almost_eq(DamageCalculator.factor_nivel(151), 3.98, 0.0001, "el nivel se limita a 150")


func test_dano_base() -> void:
	assert_almost_eq(DamageCalculator.dano_base(30.0, 1.4, 12.0, 10), 63.72, 0.0001)
	assert_almost_eq(DamageCalculator.dano_base(0.0, 1.0, 0.0, 1), 0.0, 0.0001)


func test_bono_negativo_limitado_al_40_por_ciento() -> void:
	assert_almost_eq(DamageCalculator.bono_negativo(0.0), 0.0, 0.0001)
	assert_almost_eq(DamageCalculator.bono_negativo(0.25), 0.25, 0.0001)
	assert_almost_eq(DamageCalculator.bono_negativo(0.9), 0.4, 0.0001)
	assert_almost_eq(DamageCalculator.bono_negativo(-3.0), 0.0, 0.0001)


func test_ejemplo_canonico_del_gdd() -> void:
	# POD 30, coef 1,4, plano 12, nivel 10 contra nivel 10 con 80 de defensa → 42 de daño.
	var resultado := DamageCalculator.resolver({
		"pod": 30.0,
		"coef": 1.4,
		"plano": 12.0,
		"nivel_lanzador": 10,
		"defensa_objetivo": 80.0,
		"nivel_objetivo": 10,
		"tipo": DamageTypes.FISICO,
	})
	assert_almost_eq(float(resultado["dano_base"]), 63.72, 0.0001)
	assert_almost_eq(float(resultado["mitigacion"]), 8.0 / 23.0, 0.0001)
	assert_almost_eq(float(resultado["dano_final"]), 41.5565, 0.01)
	assert_eq(int(resultado["dano_final_entero"]), 42)
	assert_false(bool(resultado["es_critico"]), "sin tirada no hay crítico")


func test_plano_automatico_cuando_no_se_declara() -> void:
	var resultado := DamageCalculator.resolver({
		"pod": 30.0,
		"coef": 1.4,
		"nivel_lanzador": 10,
		"defensa_objetivo": 80.0,
		"nivel_objetivo": 10,
		"tipo": DamageTypes.FISICO,
	})
	assert_almost_eq(float(resultado["plano"]), 27.3, 0.0001)
	assert_eq(int(resultado["dano_final_entero"]), 53)


func test_critico_multiplica_el_dano() -> void:
	var base := {
		"pod": 30.0,
		"coef": 1.4,
		"plano": 12.0,
		"nivel_lanzador": 10,
		"defensa_objetivo": 80.0,
		"nivel_objetivo": 10,
		"tipo": DamageTypes.FISICO,
	}
	var sin_critico := DamageCalculator.resolver(base)
	var con_critico := base.duplicate()
	con_critico["tirada_critico"] = 0.0
	var resultado_critico := DamageCalculator.resolver(con_critico)
	assert_true(bool(resultado_critico["es_critico"]))
	assert_almost_eq(
		float(resultado_critico["dano_final"]),
		float(sin_critico["dano_final"]) * 1.5,
		0.0001
	)


func test_modificadores_de_pvp_y_estado() -> void:
	var base := {
		"pod": 30.0,
		"coef": 1.4,
		"plano": 12.0,
		"nivel_lanzador": 10,
		"defensa_objetivo": 80.0,
		"nivel_objetivo": 10,
		"tipo": DamageTypes.FISICO,
	}
	var referencia := DamageCalculator.resolver(base)
	var pvp := base.duplicate()
	pvp["mods_pvp"] = 0.6
	assert_almost_eq(
		float(DamageCalculator.resolver(pvp)["dano_final"]),
		float(referencia["dano_final"]) * 0.6,
		0.0001
	)
	var buffeado := base.duplicate()
	buffeado["mods_estado"] = 1.3
	assert_almost_eq(
		float(DamageCalculator.resolver(buffeado)["dano_final"]),
		float(referencia["dano_final"]) * 1.3,
		0.0001
	)


func test_bono_negativo_y_penetracion_en_la_resolucion() -> void:
	var base := {
		"pod": 30.0,
		"coef": 1.4,
		"plano": 12.0,
		"nivel_lanzador": 10,
		"defensa_objetivo": 80.0,
		"nivel_objetivo": 10,
		"tipo": DamageTypes.FISICO,
	}
	var referencia := DamageCalculator.resolver(base)
	var con_bono := base.duplicate()
	con_bono["bono_negativo"] = 1.0
	var resultado := DamageCalculator.resolver(con_bono)
	assert_almost_eq(float(resultado["bono_negativo"]), 0.4, 0.0001, "el bono negativo se limita al 40 %")
	assert_almost_eq(
		float(resultado["dano_final"]),
		float(referencia["dano_final"]) * 1.4,
		0.0001
	)
	var con_penetracion := base.duplicate()
	con_penetracion["penetracion"] = 0.35
	assert_gt(
		float(DamageCalculator.resolver(con_penetracion)["dano_final"]),
		float(referencia["dano_final"]),
		"penetrar debe aumentar el daño final"
	)


func test_tipo_umbrio_usa_otra_constante_de_mitigacion() -> void:
	var fisico := DamageCalculator.resolver({
		"pod": 30.0, "coef": 1.4, "plano": 12.0, "nivel_lanzador": 10,
		"defensa_objetivo": 80.0, "nivel_objetivo": 10, "tipo": DamageTypes.FISICO,
	})
	var umbrio := DamageCalculator.resolver({
		"pod": 30.0, "coef": 1.4, "plano": 12.0, "nivel_lanzador": 10,
		"defensa_objetivo": 80.0, "nivel_objetivo": 10, "tipo": DamageTypes.UMBRIO,
	})
	assert_lt(
		float(umbrio["mitigacion"]),
		float(fisico["mitigacion"]),
		"la resistencia resonante/umbría escala más lento que la física"
	)
	assert_gt(float(umbrio["dano_final"]), float(fisico["dano_final"]))
