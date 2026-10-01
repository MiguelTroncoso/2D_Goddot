extends GutTest
## Curva de XP 1–150 — docs/design/06-progression.md §1.


func test_xp_para_subir_valores_canonicos() -> void:
	assert_eq(XpCurve.xp_para_subir(1), 65)
	assert_eq(XpCurve.xp_para_subir(10), 4250)
	assert_eq(XpCurve.xp_para_subir(25), 25625)
	assert_eq(XpCurve.xp_para_subir(50), 101250)
	assert_eq(XpCurve.xp_para_subir(75), 226875)
	assert_eq(XpCurve.xp_para_subir(100), 402500)
	assert_eq(XpCurve.xp_para_subir(149), 891765)
	assert_eq(XpCurve.xp_para_subir(150), 903750)


func test_xp_acumulada_coincide_con_la_tabla_del_gdd() -> void:
	assert_eq(XpCurve.xp_acumulada(1), 0, "en el nivel 1 no se ha acumulado nada")
	assert_eq(XpCurve.xp_acumulada(10), 12525)
	assert_eq(XpCurve.xp_acumulada(25), 203500)
	assert_eq(XpCurve.xp_acumulada(50), 1647625)
	assert_eq(XpCurve.xp_acumulada(75), 5582375)


func test_xp_total_hasta_150_es_el_valor_del_contrato() -> void:
	assert_eq(XpCurve.xp_acumulada(150), XpCurve.XP_TOTAL_A_150)
	assert_eq(XpCurve.xp_acumulada(150), 44830375)


func test_la_curva_es_monotona_creciente() -> void:
	var anterior := 0
	for nivel in range(1, 151):
		var actual := XpCurve.xp_para_subir(nivel)
		assert_gt(actual, anterior, "el nivel %d debe pedir más XP que el anterior" % nivel)
		anterior = actual


func test_bordes_de_nivel_se_limitan_sin_error() -> void:
	assert_eq(XpCurve.nivel_limitado(-5), 1)
	assert_eq(XpCurve.nivel_limitado(75), 75)
	assert_eq(XpCurve.nivel_limitado(400), XpCurve.NIVEL_MAXIMO)
	assert_eq(XpCurve.xp_para_subir(0), XpCurve.xp_para_subir(1), "nivel 0 se limita a 1")
	assert_eq(XpCurve.xp_para_subir(-50), XpCurve.xp_para_subir(1))
	assert_eq(XpCurve.xp_para_subir(151), XpCurve.xp_para_subir(150), "nivel 151 se limita a 150")
	assert_eq(XpCurve.xp_para_subir(9999), XpCurve.xp_para_subir(150))
	assert_true(XpCurve.es_nivel_maximo(150))
	assert_false(XpCurve.es_nivel_maximo(149))
	assert_true(XpCurve.es_nivel_maximo(5000), "todo lo que supera 150 es nivel máximo")


func test_tramos_de_quince_niveles() -> void:
	assert_eq(XpCurve.tramo_de_nivel(1), 1)
	assert_eq(XpCurve.tramo_de_nivel(15), 1)
	assert_eq(XpCurve.tramo_de_nivel(16), 2)
	assert_eq(XpCurve.tramo_de_nivel(30), 2)
	assert_eq(XpCurve.tramo_de_nivel(136), 10)
	assert_eq(XpCurve.tramo_de_nivel(150), 10)
	assert_eq(XpCurve.tramo_de_nivel(0), 1, "los bordes se limitan")
	assert_eq(XpCurve.tramo_de_nivel(500), 10)


func test_xp_de_criatura_por_tipo() -> void:
	assert_eq(XpCurve.xp_criatura(50), 1215, "criatura común = 1,2 % del nivel")
	assert_eq(XpCurve.xp_criatura(50, &"elite"), 3645)
	assert_eq(XpCurve.xp_criatura(50, &"minijefe"), 9720)
	assert_eq(XpCurve.xp_criatura(50, &"jefe_tramo"), 30375)
	assert_eq(XpCurve.xp_criatura(50, &"jefe_instancia"), 21870)
	assert_eq(XpCurve.xp_criatura(50, &"jefe_raid"), 72900)
	assert_eq(XpCurve.xp_criatura(50, &"desconocido"), 1215, "un tipo desconocido no multiplica")


func test_multiplicador_por_diferencia_de_nivel() -> void:
	assert_almost_eq(XpCurve.multiplicador_diferencia_nivel(10), 1.15, 0.0001)
	assert_almost_eq(XpCurve.multiplicador_diferencia_nivel(8), 1.15, 0.0001)
	assert_almost_eq(XpCurve.multiplicador_diferencia_nivel(7), 1.0, 0.0001)
	assert_almost_eq(XpCurve.multiplicador_diferencia_nivel(0), 1.0, 0.0001)
	assert_almost_eq(XpCurve.multiplicador_diferencia_nivel(-3), 1.0, 0.0001)
	assert_almost_eq(XpCurve.multiplicador_diferencia_nivel(-4), 0.6, 0.0001)
	assert_almost_eq(XpCurve.multiplicador_diferencia_nivel(-8), 0.6, 0.0001)
	assert_almost_eq(XpCurve.multiplicador_diferencia_nivel(-9), 0.25, 0.0001)
	assert_almost_eq(XpCurve.multiplicador_diferencia_nivel(-14), 0.25, 0.0001)
	assert_almost_eq(XpCurve.multiplicador_diferencia_nivel(-15), 0.0, 0.0001, "sin XP por farmear zonas obsoletas")


func test_xp_ajustada_por_nivel_del_jugador() -> void:
	assert_eq(XpCurve.xp_ajustada(50, 50), XpCurve.xp_criatura(50))
	assert_eq(XpCurve.xp_ajustada(50, 40, &"elite"), 4192, "diferencia +10 aplica 1,15")
	assert_eq(XpCurve.xp_ajustada(50, 54, &"elite"), 2187, "diferencia −4 aplica 0,60")
	assert_eq(XpCurve.xp_ajustada(50, 59), 304, "diferencia −9 aplica 0,25")
	assert_eq(XpCurve.xp_ajustada(50, 70), 0, "diferencia −20 no otorga XP")


func test_tipos_soportados() -> void:
	assert_eq(XpCurve.tipos_soportados().size(), 7)
	assert_true(XpCurve.tipos_soportados().has(&"jefe_mundial"))
