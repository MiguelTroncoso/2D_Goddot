extends GutTest
## Conversión de zona segura a márgenes lógicos (TASK-003.5).


func test_pantalla_sin_muesca_no_reserva_margenes() -> void:
	var margenes := SafeArea.margenes(
		Rect2i(0, 0, 1920, 1080),
		Rect2i(0, 0, 1920, 1080),
		Vector2(1.5, 1.5)
	)
	assert_almost_eq(float(margenes["izquierda"]), 0.0, 0.0001)
	assert_almost_eq(float(margenes["arriba"]), 0.0, 0.0001)
	assert_almost_eq(float(margenes["derecha"]), 0.0, 0.0001)
	assert_almost_eq(float(margenes["abajo"]), 0.0, 0.0001)


func test_muesca_izquierda_en_horizontal() -> void:
	# Móvil de 2400x1080 con muesca de 100 px en el borde izquierdo y escala 1.5.
	var margenes := SafeArea.margenes(
		Rect2i(0, 0, 2400, 1080),
		Rect2i(100, 0, 2200, 1080),
		Vector2(1.5, 1.5)
	)
	assert_almost_eq(float(margenes["izquierda"]), 66.666, 0.01)
	assert_almost_eq(float(margenes["derecha"]), 66.666, 0.01)
	assert_almost_eq(float(margenes["arriba"]), 0.0, 0.0001)
	assert_almost_eq(float(margenes["abajo"]), 0.0, 0.0001)


func test_barra_de_gestos_inferior() -> void:
	var margenes := SafeArea.margenes(
		Rect2i(0, 0, 1080, 2400),
		Rect2i(0, 0, 1080, 2300),
		Vector2(1.0, 1.0)
	)
	assert_almost_eq(float(margenes["abajo"]), 100.0, 0.0001)
	assert_almost_eq(float(margenes["arriba"]), 0.0, 0.0001)


func test_zona_segura_vacia_no_rompe_el_layout() -> void:
	var margenes := SafeArea.margenes(Rect2i(0, 0, 1920, 1080), Rect2i(), Vector2(1.0, 1.0))
	assert_almost_eq(float(margenes["derecha"]), 0.0, 0.0001)
	assert_almost_eq(float(margenes["abajo"]), 0.0, 0.0001)


func test_escala_de_stretch() -> void:
	assert_true(SafeArea.escala_stretch(Vector2i(1920, 1080), Vector2(1280, 720)).is_equal_approx(Vector2(1.5, 1.5)))
	assert_true(SafeArea.escala_stretch(Vector2i(1280, 720), Vector2(1280, 720)).is_equal_approx(Vector2.ONE))
	assert_true(SafeArea.escala_stretch(Vector2i(1280, 720), Vector2.ZERO).is_equal_approx(Vector2.ONE))
