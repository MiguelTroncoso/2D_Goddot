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

var _jugador: Node = null
var _margenes: Dictionary = {"izquierda": 0.0, "arriba": 0.0, "derecha": 0.0, "abajo": 0.0}


func _ready() -> void:
	get_viewport().size_changed.connect(_aplicar_zona_segura)
	_aplicar_zona_segura()
	_instalar_overlay_de_diagnostico()


## El overlay solo existe en desarrollo o con el flag `game/debug_overlay`.
## En release la escena no está exportada, así que nunca aparece (TASK-005).
func _instalar_overlay_de_diagnostico() -> void:
	var DebugOverlay = load("res://src/ui/debug_overlay.gd")
	if not DebugOverlay.habilitado() or not DebugOverlay.escena_disponible():
		return
	var overlay := (load(DebugOverlay.RUTA_ESCENA) as PackedScene).instantiate()
	add_child(overlay)
	overlay.configurar(_joystick, _jugador)


## Enlace de contexto: el HUD solo lee del jugador para mostrar valores.
func configurar_jugador(jugador: Node) -> void:
	_jugador = jugador
	for hijo in get_children():
		# Solo el overlay de diagnóstico recibe (joystick, jugador); el HUD de combate
		# se configura desde `main.gd` con su propia firma.
		if hijo.name == "DebugOverlay" and hijo.has_method("configurar"):
			hijo.configurar(_joystick, _jugador)


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

	_joystick.set_margen_seguro(izquierda, abajo)
