extends GutTest
## Regresión del bug de input táctil (TASK-003.5).
##
## Estos tests existen porque la suite anterior inyectaba el toque en coordenadas
## locales del viewport y nunca comprobaba que el joystick fuera visible ni que
## respondiera a un evento con la transformación real de pantalla.

const MainScene = preload("res://src/main.tscn")


func _montar() -> Node:
	var main := MainScene.instantiate()
	add_child_autofree(main)
	await wait_physics_frames(2)
	return main


func test_el_joystick_existe_es_visible_y_cabe_en_pantalla() -> void:
	var main := await _montar()
	var joystick = main.get_node("UI/HUD/VirtualJoystick")
	assert_not_null(joystick, "la escena principal debe instanciar el joystick")
	assert_true(joystick.is_visible_in_tree(), "el joystick debe ser visible en runtime")
	var viewport: Rect2 = joystick.get_viewport_rect()
	assert_true(viewport.has_point(joystick.posicion_reposo()), "el anillo de reposo debe estar dentro de la pantalla")
	assert_true(joystick.mouse_filter == Control.MOUSE_FILTER_IGNORE, "el joystick usa input global, no GUI")


func test_toque_en_mitad_derecha_no_activa_el_joystick() -> void:
	var main := await _montar()
	var joystick = main.get_node("UI/HUD/VirtualJoystick")
	var viewport: Vector2 = joystick.get_viewport_rect().size
	_tocar(0, Vector2(viewport.x * 0.9, viewport.y * 0.5))
	assert_false(joystick.esta_activo(), "la mitad derecha queda libre para botones de acción")
	_soltar(0, Vector2(viewport.x * 0.9, viewport.y * 0.5))


func test_toque_en_espacio_de_pantalla_activa_y_mueve_al_jugador() -> void:
	var main := await _montar()
	var joystick = main.get_node("UI/HUD/VirtualJoystick")
	var jugador: CharacterBody2D = main.get_node("World/Player")
	var viewport: Vector2 = joystick.get_viewport_rect().size
	var final_transform: Transform2D = joystick.get_viewport().get_final_transform()
	jugador.position = Vector2(960, 640)
	await wait_physics_frames(2)

	# Punto de contacto en coordenadas de pantalla reales, como llegan del sistema.
	var centro_viewport := Vector2(viewport.x * 0.25, viewport.y * 0.7)
	_tocar(1, final_transform * centro_viewport, false)
	assert_true(joystick.esta_activo(), "un toque en la zona izquierda debe activar el joystick")
	_arrastrar(1, final_transform * (centro_viewport + Vector2(90, 0)), false)
	assert_true(joystick.output.is_equal_approx(Vector2.RIGHT), "el arrastre hacia la derecha debe dar RIGHT")

	var x_inicial := jugador.position.x
	await wait_physics_frames(12)
	assert_gt(jugador.position.x, x_inicial + 1.0, "el jugador debe desplazarse con el joystick")
	assert_gt(jugador.velocity.x, 0.0, "la velocidad debe apuntar a la derecha")

	_soltar(1, final_transform * (centro_viewport + Vector2(90, 0)), false)
	assert_false(joystick.esta_activo(), "soltar debe desactivar el joystick")
	assert_eq(joystick.output, Vector2.ZERO)
	await wait_physics_frames(2)
	assert_true(jugador.velocity.is_zero_approx(), "sin toque el jugador se detiene")


func test_el_diagnostico_contabiliza_eventos() -> void:
	var main := await _montar()
	var joystick = main.get_node("UI/HUD/VirtualJoystick")
	var viewport: Vector2 = joystick.get_viewport_rect().size
	var antes: int = joystick.eventos_touch
	_tocar(2, Vector2(viewport.x * 0.2, viewport.y * 0.6))
	_arrastrar(2, Vector2(viewport.x * 0.35, viewport.y * 0.6))
	_soltar(2, Vector2(viewport.x * 0.35, viewport.y * 0.6))
	assert_gt(joystick.eventos_touch, antes, "el contador de toques alimenta el diagnóstico en pantalla")
	assert_gt(joystick.eventos_drag, 0)
	assert_true(String(joystick.ultimo_evento).begins_with("Screen"))


func test_overlay_de_diagnostico_esta_disponible_en_debug() -> void:
	var script_overlay = load("res://src/ui/debug_overlay.gd")
	assert_not_null(script_overlay, "el overlay de diagnóstico debe existir")
	assert_true(script_overlay.habilitado(), "en un build de desarrollo el overlay se habilita")
	assert_true(script_overlay.escena_disponible(), "la escena del overlay debe existir en debug")
	var main := await _montar()
	var hud = main.get_node("UI/HUD")
	var encontrados := 0
	for hijo in hud.get_children():
		if hijo.get_script() == script_overlay:
			encontrados += 1
	assert_eq(encontrados, 1, "el HUD instala el overlay solo cuando está habilitado")


func _tocar(indice: int, posicion: Vector2, local := true) -> void:
	var evento := InputEventScreenTouch.new()
	evento.index = indice
	evento.position = posicion
	evento.pressed = true
	_root_input(evento, local)


func _soltar(indice: int, posicion: Vector2, local := true) -> void:
	var evento := InputEventScreenTouch.new()
	evento.index = indice
	evento.position = posicion
	evento.pressed = false
	_root_input(evento, local)


func _arrastrar(indice: int, posicion: Vector2, local := true) -> void:
	var evento := InputEventScreenDrag.new()
	evento.index = indice
	evento.position = posicion
	_root_input(evento, local)


func _root_input(evento: InputEvent, local: bool) -> void:
	get_viewport().push_input(evento, local)
