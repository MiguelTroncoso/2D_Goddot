extends Control
## HUD de presentación: aplica la zona segura del dispositivo y muestra un panel de
## diagnóstico de input. No contiene lógica de juego ni modifica estado (ADR-005).

const SafeArea = preload("res://src/systems/safe_area.gd")

const BASE_PANEL := Rect2(48.0, 40.0, 280.0, 100.0)
const BASE_FASE := Vector2(-388.0, 40.0)
const BASE_PISTA := Vector2(-230.0, -64.0)

@onready var _joystick: Control = $VirtualJoystick
@onready var _panel: Panel = $HealthPanel
@onready var _fase: Label = $PhaseLabel
@onready var _pista: Label = $ControlsHint
@onready var _salud: ProgressBar = $HealthPanel/HealthPlaceholder
@onready var _diagnostico: Label = $DiagnosticoLabel

var _jugador: Node = null
var _margenes: Dictionary = {"izquierda": 0.0, "arriba": 0.0, "derecha": 0.0, "abajo": 0.0}
var _acumulador_diagnostico := 0.0


func _ready() -> void:
	get_viewport().size_changed.connect(_aplicar_zona_segura)
	_aplicar_zona_segura()


## Enlace de contexto: el HUD solo lee del jugador para mostrar valores.
func configurar_jugador(jugador: Node) -> void:
	_jugador = jugador


func _aplicar_zona_segura() -> void:
	var ventana := DisplayServer.window_get_size()
	var viewport := get_viewport().get_visible_rect().size
	_margenes = SafeArea.margenes(
		Rect2i(Vector2i.ZERO, ventana),
		DisplayServer.get_display_safe_area(),
		SafeArea.escala_stretch(ventana, viewport)
	)
	var izquierda: float = _margenes["izquierda"]
	var arriba: float = _margenes["arriba"]
	var derecha: float = _margenes["derecha"]
	var abajo: float = _margenes["abajo"]

	_panel.offset_left = BASE_PANEL.position.x + izquierda
	_panel.offset_top = BASE_PANEL.position.y + arriba
	_panel.offset_right = BASE_PANEL.end.x + izquierda
	_panel.offset_bottom = BASE_PANEL.end.y + arriba

	_fase.offset_left = BASE_FASE.x - derecha
	_fase.offset_top = BASE_FASE.y + arriba
	_fase.offset_right = -48.0 - derecha
	_fase.offset_bottom = BASE_FASE.y + 34.0 + arriba

	_pista.offset_top = BASE_PISTA.y - abajo
	_pista.offset_bottom = BASE_PISTA.y + 32.0 - abajo

	_diagnostico.offset_right = -48.0 - derecha
	_diagnostico.offset_top = 96.0 + arriba
	_diagnostico.offset_bottom = 226.0 + arriba

	_joystick.set_margen_seguro(izquierda, abajo)


func alternar_diagnostico() -> void:
	_diagnostico.visible = not _diagnostico.visible


func _process(delta: float) -> void:
	_acumulador_diagnostico += delta
	if _acumulador_diagnostico < 0.25 or not _diagnostico.visible:
		return
	_acumulador_diagnostico = 0.0
	var ventana := DisplayServer.window_get_size()
	var viewport := get_viewport().get_visible_rect().size
	var velocidad := Vector2.ZERO
	if is_instance_valid(_jugador):
		velocidad = _jugador.velocity
	_diagnostico.text = "\n".join([
		"FPS %d · vp %dx%d · win %dx%d" % [
			Engine.get_frames_per_second(), int(viewport.x), int(viewport.y), ventana.x, ventana.y
		],
		"safe L%d T%d R%d B%d" % [
			int(_margenes["izquierda"]), int(_margenes["arriba"]),
			int(_margenes["derecha"]), int(_margenes["abajo"]),
		],
		"touch %d · drag %d · último %s" % [
			_joystick.eventos_touch, _joystick.eventos_drag, _joystick.ultimo_evento
		],
		"joy (%.2f, %.2f) · vel (%d, %d)" % [
			_joystick.output.x, _joystick.output.y, int(velocidad.x), int(velocidad.y)
		],
	] as Array[String])
