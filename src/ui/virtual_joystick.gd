extends Control
## Joystick dinámico para Android (TASK-003.5).
##
## Reglas de diseño tras el bug de input en dispositivo:
## 1. El vector de movimiento sale del DESPLAZAMIENTO RELATIVO desde el punto donde
##    el dedo tocó. Nunca se mezclan transformaciones de canvas, escala de stretch
##    ni safe area: si el dedo se mueve 60 px, eso es lo único que importa, en
##    cualquier pantalla y densidad.
## 2. La zona de activación es la mitad izquierda de la pantalla, no un círculo
##    fijo: un toque en cualquier parte de esa mitad enciende el joystick y el
##    anillo aparece bajo el dedo.
## 3. El anillo de reposo se dibuja siempre (con margen de safe area) para que el
##    jugador sepa dónde está el control.
##
## Presentación pura: la matemática de dirección vive en `systems/movement_input.gd`.

signal movement_changed(direction: Vector2)

const MovementInput = preload("res://src/systems/movement_input.gd")

const RADIO_BASE := 96.0
const RADIO_KNOB := 34.0
const TRAVEL := RADIO_BASE - RADIO_KNOB
const MARGEN_REPOSO := Vector2(64.0, 64.0)

@export_range(0.0, 0.9, 0.01) var dead_zone: float = 0.15
@export_range(0.05, 1.0, 0.05) var zona_activacion: float = MovementInput.ZONA_ACTIVACION_RATIO

var output := Vector2.ZERO

var _finger: int = -1
var _origen := Vector2.ZERO
var _actual := Vector2.ZERO
var _margen_seguro := Vector2.ZERO

# Diagnóstico en pantalla (no afecta al juego; lo consume `hud.gd`).
var eventos_touch: int = 0
var eventos_drag: int = 0
var ultimo_evento: String = "ninguno"
var origen_actual := Vector2.ZERO


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	resized.connect(_on_resized)


## Margen (izquierda, abajo) en unidades lógicas, calculado por el HUD con SafeArea.
func set_margen_seguro(izquierda: float, abajo: float) -> void:
	_margen_seguro = Vector2(maxf(0.0, izquierda), maxf(0.0, abajo))
	queue_redraw()


func esta_activo() -> bool:
	return _finger != -1


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		eventos_touch += 1
		ultimo_evento = "ScreenTouch %s" % ("pressed" if event.pressed else "released")
		if event.index == _finger and (not event.pressed or event.canceled):
			reset()
			get_viewport().set_input_as_handled()
		elif event.pressed and not event.canceled and _finger == -1:
			if MovementInput.en_zona_activacion(event.position, _tamano_viewport(), zona_activacion):
				_finger = event.index
				_origen = event.position
				_actual = event.position
				origen_actual = event.position
				_emitir(Vector2.ZERO)
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		eventos_drag += 1
		ultimo_evento = "ScreenDrag"
		if event.index == _finger:
			_actual = event.position
			_emitir(MovementInput.vector_desde_origen(_origen, _actual, TRAVEL, dead_zone))
			get_viewport().set_input_as_handled()


func reset() -> void:
	_finger = -1
	_origen = Vector2.ZERO
	_actual = Vector2.ZERO
	origen_actual = Vector2.ZERO
	if output != Vector2.ZERO:
		_emitir(Vector2.ZERO)
	else:
		queue_redraw()


func _emitir(valor: Vector2) -> void:
	output = valor
	movement_changed.emit(output)
	queue_redraw()


func _tamano_viewport() -> Vector2:
	return get_viewport().get_visible_rect().size


## Centro del anillo en reposo, en coordenadas de viewport.
func posicion_reposo() -> Vector2:
	var tamano := _tamano_viewport()
	return Vector2(
		MARGEN_REPOSO.x + _margen_seguro.x,
		tamano.y - MARGEN_REPOSO.y - _margen_seguro.y
	)


func _a_local(punto_viewport: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * punto_viewport


func _on_resized() -> void:
	reset()
	queue_redraw()


func _on_visibility_changed() -> void:
	reset()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		reset()


func _draw() -> void:
	var casa := _a_local(posicion_reposo())
	var activo := _finger != -1
	var centro := _a_local(_origen) if activo else casa

	# Anillo de reposo: siempre visible para que el control sea descubrible.
	draw_circle(casa, RADIO_BASE, Color(0.05, 0.10, 0.14, 0.55))
	draw_arc(casa, RADIO_BASE, 0.0, TAU, 64, Color(0.55, 0.78, 0.78, 0.85), 3.0, true)
	draw_circle(casa, RADIO_KNOB, Color(0.45, 0.85, 0.78, 0.75))

	if activo:
		draw_arc(centro, RADIO_BASE, 0.0, TAU, 64, Color(0.95, 0.78, 0.36, 0.95), 4.0, true)
		var desplazamiento := (_actual - _origen).limit_length(TRAVEL)
		draw_circle(centro + desplazamiento, RADIO_KNOB, Color(0.98, 0.83, 0.42, 0.98))
	else:
		# Flechas de referencia dentro del anillo de reposo.
		var color := Color(0.62, 0.80, 0.80, 0.75)
		draw_line(casa + Vector2(-26, 0), casa + Vector2(26, 0), color, 2.0)
		draw_line(casa + Vector2(0, -26), casa + Vector2(0, 26), color, 2.0)
