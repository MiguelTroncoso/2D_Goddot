extends GutTest
## Matemática de dirección del joystick dinámico (TASK-003.5).

const MovementInput = preload("res://src/systems/movement_input.gd")


func test_combine_no_supera_velocidad_maxima() -> void:
	assert_true(MovementInput.combine(Vector2.RIGHT, Vector2.DOWN).length() <= 1.0)
	assert_eq(MovementInput.combine(Vector2.RIGHT, Vector2.LEFT), Vector2.ZERO)


func test_joystick_vector_zona_muerta_y_recorrido() -> void:
	assert_eq(MovementInput.joystick_vector(Vector2.ZERO, 62.0, 0.15), Vector2.ZERO)
	assert_eq(MovementInput.joystick_vector(Vector2(5, 0), 62.0, 0.15), Vector2.ZERO)
	assert_true(MovementInput.joystick_vector(Vector2(62, 0), 62.0, 0.15).is_equal_approx(Vector2.RIGHT))
	assert_true(MovementInput.joystick_vector(Vector2(500, 0), 62.0, 0.15).is_equal_approx(Vector2.RIGHT))
	assert_eq(MovementInput.joystick_vector(Vector2.RIGHT, 0.0, 0.15), Vector2.ZERO)


func test_delta_desde_origen() -> void:
	assert_eq(MovementInput.delta_desde_origen(Vector2(10, 10), Vector2(70, 10)), Vector2(60, 0))
	assert_eq(MovementInput.delta_desde_origen(Vector2(10, 10), Vector2(10, 10)), Vector2.ZERO)


func test_vector_desde_origen_en_las_cuatro_direcciones() -> void:
	var origen := Vector2(300, 400)
	assert_true(
		MovementInput.vector_desde_origen(origen, origen + Vector2(80, 0), 62.0, 0.15)
		.is_equal_approx(Vector2.RIGHT)
	)
	assert_true(
		MovementInput.vector_desde_origen(origen, origen + Vector2(-80, 0), 62.0, 0.15)
		.is_equal_approx(Vector2.LEFT)
	)
	assert_true(
		MovementInput.vector_desde_origen(origen, origen + Vector2(0, -80), 62.0, 0.15)
		.is_equal_approx(Vector2.UP)
	)
	assert_true(
		MovementInput.vector_desde_origen(origen, origen + Vector2(0, 80), 62.0, 0.15)
		.is_equal_approx(Vector2.DOWN)
	)


func test_vector_desde_origen_respeta_zona_muerta() -> void:
	var origen := Vector2(100, 100)
	assert_eq(MovementInput.vector_desde_origen(origen, origen + Vector2(4, 4), 62.0, 0.15), Vector2.ZERO)
	var suave := MovementInput.vector_desde_origen(origen, origen + Vector2(31, 0), 62.0, 0.15)
	assert_gt(suave.length(), 0.0)
	assert_lt(suave.length(), 1.0, "el desplazamiento corto da velocidad proporcional")


func test_zona_de_activacion_cubre_la_mitad_izquierda() -> void:
	var viewport := Vector2(1280.0, 720.0)
	assert_true(MovementInput.en_zona_activacion(Vector2(100, 400), viewport), "izquierda baja")
	assert_true(MovementInput.en_zona_activacion(Vector2(640, 400), viewport), "centro izquierdo")
	assert_true(MovementInput.en_zona_activacion(Vector2(700, 700), viewport), "borde de la zona")
	assert_false(MovementInput.en_zona_activacion(Vector2(760, 400), viewport), "mitad derecha")
	assert_false(MovementInput.en_zona_activacion(Vector2(100, 40), viewport), "franja superior del HUD")
	assert_false(MovementInput.en_zona_activacion(Vector2(-10, 400), viewport), "fuera por la izquierda")
	assert_false(MovementInput.en_zona_activacion(Vector2(100, 900), viewport), "fuera por abajo")
	assert_false(MovementInput.en_zona_activacion(Vector2(10, 10), Vector2.ZERO), "viewport sin tamaño")


func test_zona_de_activacion_se_puede_ampliar() -> void:
	var viewport := Vector2(1280.0, 720.0)
	assert_true(MovementInput.en_zona_activacion(Vector2(1100, 400), viewport, 1.0), "pantalla completa")
	assert_false(MovementInput.en_zona_activacion(Vector2(1100, 400), viewport, 0.5))
