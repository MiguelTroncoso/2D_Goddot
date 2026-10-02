extends GutTest
## Patrones de IA: 3 implementados + 6 declarados pendientes (TASK-004).

const PENDIENTES := [
	&"errante", &"territorial", &"manada", &"emboscada", &"guardian", &"jefe",
]


func _contexto(extra: Dictionary = {}) -> Dictionary:
	var base := {
		"distancia": 10.0,
		"vida_pct": 1.0,
		"objetivo_valido": true,
		"en_combate": false,
		"radio_deteccion": 6.0,
		"radio_agarre": 12.0,
		"radio_ataque": 1.5,
		"tiempo": 0.0,
		"semilla": 0.0,
		"posicion_actual": Vector2.ZERO,
		"posicion_objetivo": Vector2(10, 0),
		"posicion_guardia": Vector2.ZERO,
	}
	for clave in extra:
		base[clave] = extra[clave]
	return base


func test_catalogo_de_patrones() -> void:
	assert_eq(AiPatterns.patrones_implementados().size(), 3)
	assert_eq(AiPatterns.patrones_pendientes().size(), 6)
	assert_true(AiPatterns.esta_implementado(&"pasivo"))
	assert_false(AiPatterns.esta_implementado(&"jefe"))
	assert_true(AiPatterns.es_valido(&"jefe"), "los pendientes siguen siendo patrones válidos de datos")
	assert_false(AiPatterns.es_valido(&"inventado"))
	assert_eq(AiPatterns.normalizar(&"inventado"), AiPatterns.PATRON_POR_DEFECTO)
	assert_eq(AiPatterns.normalizar(&"agresivo"), &"agresivo")


func test_estado_inicial_por_patron() -> void:
	assert_eq(AiPatterns.estado_inicial(&"pasivo"), AiPatterns.ESTADO_IDLE)
	assert_eq(AiPatterns.estado_inicial(&"agresivo"), AiPatterns.ESTADO_IDLE)
	assert_eq(AiPatterns.estado_inicial(&"patrulla"), AiPatterns.ESTADO_PATRULLAR)


func test_pasivo_no_reacciona_sin_dano() -> void:
	var decision := AiPatterns.decidir(&"pasivo", _contexto({"distancia": 1.0}))
	assert_eq(decision["estado"], AiPatterns.ESTADO_IDLE)
	assert_false(bool(decision["atacar"]))
	assert_eq(decision["mover_hacia"], Vector2.ZERO)


func test_pasivo_huye_con_vida_baja_y_persigue_al_ser_golpeado() -> void:
	var herido := AiPatterns.decidir(&"pasivo", _contexto({
		"en_combate": true, "vida_pct": 0.15, "distancia": 2.0,
		"posicion_objetivo": Vector2(2, 0),
	}))
	assert_eq(herido["estado"], AiPatterns.ESTADO_HUIR)
	assert_true(herido["mover_hacia"].x < 0.0, "huye en dirección opuesta al atacante")

	var persiguiendo := AiPatterns.decidir(&"pasivo", _contexto({
		"en_combate": true, "vida_pct": 0.9, "distancia": 5.0,
		"posicion_objetivo": Vector2(5, 0),
	}))
	assert_eq(persiguiendo["estado"], AiPatterns.ESTADO_PERSEGUIR)
	assert_true(persiguiendo["mover_hacia"].x > 0.0)

	var golpeando := AiPatterns.decidir(&"pasivo", _contexto({
		"en_combate": true, "vida_pct": 0.9, "distancia": 1.0,
		"posicion_objetivo": Vector2(1, 0),
	}))
	assert_eq(golpeando["estado"], AiPatterns.ESTADO_ATACAR)
	assert_true(bool(golpeando["atacar"]))


func test_agresivo_detecta_persigue_y_vuelve() -> void:
	var detectado := AiPatterns.decidir(&"agresivo", _contexto({"distancia": 5.0}))
	assert_eq(detectado["estado"], AiPatterns.ESTADO_PERSEGUIR)

	var en_rango := AiPatterns.decidir(&"agresivo", _contexto({"distancia": 1.2}))
	assert_eq(en_rango["estado"], AiPatterns.ESTADO_ATACAR)
	assert_true(bool(en_rango["atacar"]))

	var lejos := AiPatterns.decidir(&"agresivo", _contexto({"distancia": 40.0}))
	assert_eq(lejos["estado"], AiPatterns.ESTADO_VOLVER)

	var sin_objetivo := AiPatterns.decidir(&"agresivo", _contexto({"objetivo_valido": false}))
	assert_eq(sin_objetivo["estado"], AiPatterns.ESTADO_IDLE)

	var fuera_de_deteccion := AiPatterns.decidir(&"agresivo", _contexto({"distancia": 9.0}))
	assert_eq(fuera_de_deteccion["estado"], AiPatterns.ESTADO_IDLE)


func test_patrulla_es_determinista_por_tramo_y_reacciona() -> void:
	var tramo_uno := AiPatterns.decidir(&"patrulla", _contexto({"distancia": 40.0, "tiempo": 0.5}))
	var mismo_tramo := AiPatterns.decidir(&"patrulla", _contexto({"distancia": 40.0, "tiempo": 2.5}))
	var otro_tramo := AiPatterns.decidir(&"patrulla", _contexto({"distancia": 40.0, "tiempo": 3.5}))
	assert_eq(tramo_uno["estado"], AiPatterns.ESTADO_PATRULLAR)
	assert_eq(tramo_uno["mover_hacia"], mismo_tramo["mover_hacia"], "dentro del tramo no cambia")
	assert_ne(tramo_uno["mover_hacia"], otro_tramo["mover_hacia"], "al cambiar de tramo cambia la dirección")

	var reacciona := AiPatterns.decidir(&"patrulla", _contexto({"distancia": 1.0}))
	assert_eq(reacciona["estado"], AiPatterns.ESTADO_ATACAR)


func test_patrones_pendientes_devuelven_no_implementado_sin_fallar() -> void:
	for patron in PENDIENTES:
		var decision := AiPatterns.decidir(patron, _contexto())
		assert_not_null(decision, "%s no debe devolver null" % patron)
		assert_eq(decision["estado"], AiPatterns.ESTADO_NO_IMPLEMENTADO, patron)
		assert_true(bool(decision["no_implementado"]), "%s debe marcar no_implementado" % patron)
		assert_false(bool(decision["atacar"]))
		assert_eq(decision["mover_hacia"], Vector2.ZERO)


func test_patron_desconocido_cae_al_por_defecto() -> void:
	var decision := AiPatterns.decidir(&"inventado", _contexto())
	assert_eq(decision["estado"], AiPatterns.ESTADO_NO_IMPLEMENTADO)
	assert_eq(decision["patron_pendiente"], AiPatterns.PATRON_POR_DEFECTO)


func test_ai_system_lleva_estado_y_fases() -> void:
	var sistema := AiSystem.new()
	watch_signals(sistema)
	assert_eq(sistema.decisiones_tomadas(), 0)
	assert_eq(sistema.estado_actual(&"mob"), &"")
	var primera := sistema.decidir(&"mob", &"pasivo", _contexto({"en_combate": true, "distancia": 5.0}))
	assert_eq(primera["estado"], AiPatterns.ESTADO_PERSEGUIR)
	assert_eq(sistema.estado_actual(&"mob"), AiPatterns.ESTADO_PERSEGUIR)
	assert_eq(primera["estado_anterior"], AiPatterns.ESTADO_IDLE)
	assert_signal_emitted(sistema, "estado_cambiado")
	assert_eq(sistema.decisiones_tomadas(), 1)

	var misma := sistema.decidir(&"mob", &"pasivo", _contexto({"en_combate": true, "distancia": 5.0}))
	assert_eq(misma["estado"], AiPatterns.ESTADO_PERSEGUIR, "sin cambio de estado no se emite señal nueva")
	assert_eq(sistema.fase_actual(&"mob"), 1)
	sistema.estados_registrados(&"mob", AiPatterns.ESTADO_ATACAR)
	assert_eq(sistema.estado_actual(&"mob"), AiPatterns.ESTADO_ATACAR)
	sistema.olvidar(&"mob")
	assert_eq(sistema.estado_actual(&"mob"), &"")
	sistema.reiniciar()
	assert_eq(sistema.decisiones_tomadas(), 0)
