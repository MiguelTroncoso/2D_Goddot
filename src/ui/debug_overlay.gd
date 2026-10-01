extends Control

## Overlay de diagnóstico (FPS, joystick, velocidad, safe area).
##
## Solo se instancia cuando el proceso es de desarrollo o cuando el PO lo activa con
## `game/debug_overlay=true` en project.godot. En el APK de release la escena queda
## fuera del paquete (`exclude_filter` del preset "Android Release") y el HUD no la
## carga, así que nunca aparece en producción (TASK-005).
##
## Presentación pura: solo lee estado de otros nodos para mostrarlo.

const RUTA_ESCENA := "res://src/ui/debug_overlay.tscn"

@onready var _etiqueta: Label = $Panel/Label

var _joystick: Node = null
var _jugador: Node = null
var _acumulador := 0.0


## ¿Corresponde mostrar el overlay en este proceso?
static func habilitado() -> bool:
	if OS.is_debug_build():
		return true
	return bool(ProjectSettings.get_setting("game/debug_overlay", false))


## ¿Existe la escena en este paquete? En release no está exportada.
static func escena_disponible() -> bool:
	return ResourceLoader.exists(RUTA_ESCENA)


func configurar(joystick: Node, jugador: Node) -> void:
	_joystick = joystick
	_jugador = jugador


func _process(delta: float) -> void:
	_acumulador += delta
	if _acumulador < 0.25:
		return
	_acumulador = 0.0
	if not is_instance_valid(_etiqueta):
		return
	var ventana := DisplayServer.window_get_size()
	var viewport := get_viewport().get_visible_rect().size
	var seguro := DisplayServer.get_display_safe_area()
	var vector := Vector2.ZERO
	var velocidad := Vector2.ZERO
	var toques := 0
	var arrastres := 0
	var ultimo := "sin datos"
	if is_instance_valid(_joystick):
		vector = _joystick.output
		toques = _joystick.eventos_touch
		arrastres = _joystick.eventos_drag
		ultimo = _joystick.ultimo_evento
	if is_instance_valid(_jugador):
		velocidad = _jugador.velocity
	_etiqueta.text = "\n".join([
		"FPS %d · vp %dx%d · win %dx%d" % [
			Engine.get_frames_per_second(), int(viewport.x), int(viewport.y), ventana.x, ventana.y
		],
		"safe %dx%d+%d+%d" % [seguro.size.x, seguro.size.y, seguro.position.x, seguro.position.y],
		"touch %d · drag %d · último %s" % [toques, arrastres, ultimo],
		"joy (%.2f, %.2f) · vel (%d, %d)" % [
			vector.x, vector.y, int(velocidad.x), int(velocidad.y)
		],
	] as Array[String])
