extends GutTest
## Orquestación de combate: casos borde (TASK-004).

const JUGADOR := &"jugador"
const ENEMIGO := &"enemigo"


func _sistema(semilla: int = 7, vida_jugador: float = 200.0, vida_enemigo: float = 100.0) -> CombatSystem:
	var sistema := CombatSystem.new(semilla)
	sistema.registrar_actor(JUGADOR, &"jugador", StatBlock.base(5), vida_jugador, vida_jugador)
	sistema.registrar_actor(ENEMIGO, &"enemigo", StatBlock.base(3), vida_enemigo, vida_enemigo)
	return sistema


func test_registro_y_consultas_de_actores() -> void:
	var sistema := _sistema()
	assert_eq(sistema.actores().size(), 2)
	assert_true(sistema.tiene_actor(JUGADOR))
	assert_false(sistema.tiene_actor(&"fantasma"))
	assert_almost_eq(sistema.vida(JUGADOR), 200.0, 0.0001)
	assert_almost_eq(sistema.vida_max(JUGADOR), 200.0, 0.0001, "la Vida máxima es la declarada")
	assert_almost_eq(sistema.vida_porcentaje(JUGADOR), 1.0, 0.0001, "200/200 es 100 %")
	assert_true(sistema.esta_vivo(JUGADOR))
	assert_eq(sistema.bando(ENEMIGO), &"enemigo")
	assert_not_null(sistema.stats(ENEMIGO))
	assert_eq(sistema.eventos_emitidos(), 0)


func test_ataque_basico_aplica_dano_y_emite_evento() -> void:
	var sistema := _sistema()
	watch_signals(sistema)
	var resultado := sistema.atacar(JUGADOR, ENEMIGO, {"coef": 1.0, "tipo": DamageTypes.FISICO})
	assert_true(bool(resultado["exito"]))
	assert_gt(float(resultado["dano"]), 0.0)
	assert_lt(sistema.vida(ENEMIGO), 100.0)
	assert_gt(sistema.eventos_emitidos(), 0)
	assert_signal_emitted(sistema, "dano_aplicado")


func test_desglose_auditable_completo() -> void:
	var sistema := _sistema()
	var resultado := sistema.atacar(JUGADOR, ENEMIGO, {"coef": 1.0})
	var desglose: Dictionary = resultado["desglose"]
	for campo in [
		"pod", "coef", "plano", "nivel_lanzador", "nivel_objetivo", "tipo", "factor_nivel",
		"dano_base", "defensa_efectiva", "mitigacion", "bono_negativo", "mods_estado",
		"mods_pvp", "es_critico", "multiplicador_critico", "dano_final", "dano_final_entero",
	]:
		assert_true(desglose.has(campo), "el desglose debe incluir '%s'" % campo)
	assert_almost_eq(float(resultado["dano"]), float(desglose["dano_final"]), 0.0001)


func test_critico_exactamente_en_el_limite() -> void:
	var sistema := CombatSystem.new(1)
	var critico := StatBlock.base(5)
	critico.critico_extra = 0.45
	sistema.registrar_actor(JUGADOR, &"jugador", critico, 200.0, 200.0)
	sistema.registrar_actor(ENEMIGO, &"enemigo", StatBlock.base(3), 500.0, 500.0)
	assert_almost_eq(critico.critico(), 0.50, 0.0001, "el tope de crítico es 50 %")

	var justo_dentro := sistema.atacar(JUGADOR, ENEMIGO, {"coef": 1.0, "tirada_critico": 0.499})
	assert_true(bool(justo_dentro["es_critico"]), "0,499 < 0,50 debe ser crítico")
	var en_el_limite := sistema.atacar(JUGADOR, ENEMIGO, {"coef": 1.0, "tirada_critico": 0.50})
	assert_false(bool(en_el_limite["es_critico"]), "0,50 no es menor que 0,50: no hay crítico")
	assert_gt(
		float(justo_dentro["dano"]),
		float(en_el_limite["dano"]),
		"el crítico debe multiplicar el daño"
	)


func test_rng_extremos() -> void:
	var sistema := CombatSystem.new(1)
	var atacante := StatBlock.base(5)
	atacante.critico_extra = 0.20
	sistema.registrar_actor(JUGADOR, &"jugador", atacante, 200.0, 200.0)
	sistema.registrar_actor(ENEMIGO, &"enemigo", StatBlock.base(3), 500.0, 500.0)
	var cero := sistema.atacar(JUGADOR, ENEMIGO, {"coef": 1.0, "tirada_critico": 0.0})
	assert_true(bool(cero["es_critico"]), "tirada 0.0 siempre entra en el rango crítico")
	var uno := sistema.atacar(JUGADOR, ENEMIGO, {"coef": 1.0, "tirada_critico": 1.0})
	assert_false(bool(uno["es_critico"]), "tirada 1.0 nunca es crítica")


func test_rng_determinista_con_la_misma_semilla() -> void:
	var a := _sistema(99, 200.0, 100000.0)
	var b := _sistema(99, 200.0, 100000.0)
	for indice in range(5):
		var golpe_a := a.atacar(JUGADOR, ENEMIGO, {"coef": 1.0, "ignorar_cooldown": true})
		var golpe_b := b.atacar(JUGADOR, ENEMIGO, {"coef": 1.0, "ignorar_cooldown": true})
		assert_almost_eq(float(golpe_a["dano"]), float(golpe_b["dano"]), 0.0001, "golpe %d" % indice)


func test_mitigacion_al_tope_y_dano_minimo() -> void:
	var sistema := CombatSystem.new(3)
	sistema.registrar_actor(JUGADOR, &"jugador", StatBlock.base(5), 200.0, 200.0)
	var muro := StatBlock.base(3)
	muro.defensa_extra = 1000000.0
	sistema.registrar_actor(ENEMIGO, &"enemigo", muro, 100.0, 100.0)
	var resultado := sistema.atacar(JUGADOR, ENEMIGO, {"coef": 1.0, "tirada_critico": 1.0})
	assert_almost_eq(float(resultado["desglose"]["mitigacion"]), 0.75, 0.0001, "tope del 75 %")
	var esperado := float(resultado["desglose"]["dano_base"]) * 0.25
	assert_almost_eq(float(resultado["dano"]), esperado, 0.01)


func test_ataque_sin_poder_hace_dano_cero() -> void:
	var sistema := _sistema()
	var resultado := sistema.atacar(JUGADOR, ENEMIGO, {"coef": 0.0, "tirada_critico": 1.0})
	assert_true(bool(resultado["exito"]))
	assert_almost_eq(float(resultado["dano"]), 0.0, 0.0001)
	assert_almost_eq(sistema.vida(ENEMIGO), 100.0, 0.0001, "la vida no cambia con daño 0")


func test_no_se_puede_atacar_a_uno_mismo() -> void:
	var sistema := _sistema()
	var resultado := sistema.atacar(JUGADOR, JUGADOR, {"coef": 1.0})
	assert_false(bool(resultado["exito"]))
	assert_eq(String(resultado["razon"]), "self_target")
	assert_almost_eq(sistema.vida(JUGADOR), 200.0, 0.0001, "el auto-ataque no hace daño")


func test_dano_directo_mitiga_sin_critico() -> void:
	var sistema := _sistema()
	var resultado := sistema.aplicar_dano(JUGADOR, ENEMIGO, 100.0, DamageTypes.RESONANTE, &"dot")
	assert_true(bool(resultado["exito"]))
	assert_false(bool(resultado["es_critico"]))
	assert_lt(float(resultado["dano"]), 100.0, "el daño directo también se mitiga")
	var fantasma := sistema.aplicar_dano(JUGADOR, &"nadie", 10.0)
	assert_false(bool(fantasma["exito"]))


func test_cooldowns_y_reinicio() -> void:
	var sistema := _sistema()
	var datos := {"coef": 1.0, "habilidad": &"golpe", "cooldown": 2.0}
	assert_true(sistema.puede_atacar(JUGADOR, &"golpe", 0.0))
	sistema.atacar(JUGADOR, ENEMIGO, datos, 0.0)
	assert_false(sistema.puede_atacar(JUGADOR, &"golpe", 1.0))
	assert_almost_eq(sistema.enfriamiento_restante(JUGADOR, &"golpe", 1.0), 1.0, 0.0001)
	assert_true(sistema.puede_atacar(JUGADOR, &"golpe", 2.0))
	var bloqueado := sistema.atacar(JUGADOR, ENEMIGO, datos, 2.1)
	assert_true(bool(bloqueado["exito"]), "a los 2 s el cooldown ya expiró")
	sistema.reiniciar_cooldowns(JUGADOR)
	assert_true(sistema.puede_atacar(JUGADOR, &"golpe", 2.1))


func test_ataque_en_enfriamiento_y_objetivo_muerto() -> void:
	var sistema := _sistema(5, 200.0, 5000.0)
	sistema.atacar(JUGADOR, ENEMIGO, {"coef": 0.2, "habilidad": &"fuerte", "cooldown": 5.0}, 10.0)
	var repetido := sistema.atacar(JUGADOR, ENEMIGO, {"coef": 0.2, "habilidad": &"fuerte"}, 11.0)
	assert_eq(String(repetido["razon"]), "en_enfriamiento")
	var sobrante := sistema.aplicar_dano(JUGADOR, ENEMIGO, 99999.0)
	assert_true(bool(sobrante["objetivo_derrotado"]))
	assert_false(sistema.esta_vivo(ENEMIGO))
	assert_eq(String(sistema.atacar(JUGADOR, ENEMIGO, {})["razon"]), "objetivo_no_disponible")


func test_derrota_emite_senal_y_desregistro() -> void:
	var sistema := _sistema(5, 200.0, 30.0)
	watch_signals(sistema)
	sistema.aplicar_dano(JUGADOR, ENEMIGO, 500.0)
	assert_signal_emitted(sistema, "actor_derrotado")
	sistema.desregistrar_actor(ENEMIGO)
	assert_false(sistema.tiene_actor(ENEMIGO))
	assert_eq(sistema.actores().size(), 1)


func test_curacion_respeta_el_maximo() -> void:
	var sistema := _sistema()
	sistema.aplicar_dano(JUGADOR, JUGADOR, 0.0)
	var dano := sistema.aplicar_dano(&"entorno", JUGADOR, 80.0)
	assert_true(bool(dano["exito"]))
	watch_signals(sistema)
	var curacion := sistema.curar(JUGADOR, 1000.0, &"pocion")
	assert_true(bool(curacion["exito"]))
	assert_almost_eq(sistema.vida(JUGADOR), 200.0, 0.0001, "no se cura por encima del máximo")
	assert_signal_emitted(sistema, "curacion_aplicada")
	var fantasma := sistema.curar(&"nadie", 10.0)
	assert_false(bool(fantasma["exito"]))


func test_modificador_pvp_entre_jugadores() -> void:
	var sistema := CombatSystem.new(11)
	var atacante := StatBlock.base(10)
	atacante.critico_extra = 0.0
	sistema.registrar_actor(&"a", &"jugador", atacante, 500.0, 500.0)
	sistema.registrar_actor(&"b", &"jugador", StatBlock.base(10), 500.0, 500.0)
	sistema.registrar_actor(&"c", &"enemigo", StatBlock.base(10), 500.0, 500.0)
	var pvp := sistema.atacar(&"a", &"b", {"coef": 1.0, "tirada_critico": 1.0})
	var pve := sistema.atacar(&"a", &"c", {"coef": 1.0, "tirada_critico": 1.0})
	assert_almost_eq(float(pvp["desglose"]["mods_pvp"]), 0.6, 0.0001)
	assert_almost_eq(float(pve["desglose"]["mods_pvp"]), 1.0, 0.0001)
	assert_lt(float(pvp["dano"]), float(pve["dano"]), "PvP pega menos que PvE")
