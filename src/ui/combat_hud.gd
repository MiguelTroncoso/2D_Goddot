extends Control

## HUD de combate (TASK-004): vida del enemigo objetivo, cooldown del ataque y
## números de daño flotantes. Solo presenta; la lógica vive en `systems/`.

signal ataque_presionado

const DURACION_DANO := 0.7

@onready var _panel: Panel = $PanelEnemigo
@onready var _nombre: Label = $PanelEnemigo/Nombre
@onready var _vida: ProgressBar = $PanelEnemigo/Vida
@onready var _cooldown: ProgressBar = $Cooldown
@onready var _boton: Button = $BotonAtacar

var _jugador: Node = null


func _ready() -> void:
	_boton.pressed.connect(func() -> void: ataque_presionado.emit())
	limpiar_enemigo()


func configurar(jugador: Node) -> void:
	_jugador = jugador


func mostrar_enemigo(nombre: String, vida: float, vida_max: float) -> void:
	_panel.visible = true
	_nombre.text = nombre
	_vida.max_value = maxf(1.0, vida_max)
	_vida.value = clampf(vida, 0.0, _vida.max_value)


func limpiar_enemigo() -> void:
	_panel.visible = false
	_nombre.text = ""
	_vida.value = 0.0


func actualizar_cooldown(porcentaje: float) -> void:
	_cooldown.value = clampf(porcentaje, 0.0, 1.0) * 100.0


## Etiqueta temporal que sube y se desvanece sobre la posición de mundo indicada.
func mostrar_dano(cantidad: int, posicion_mundo: Vector2, es_critico: bool = false) -> void:
	var etiqueta := Label.new()
	etiqueta.text = "-%d" % cantidad
	etiqueta.add_theme_font_size_override("font_size", 26 if es_critico else 20)
	etiqueta.add_theme_color_override(
		"font_color",
		Color(1.0, 0.85, 0.35) if es_critico else Color(0.95, 0.55, 0.45)
	)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(etiqueta)
	var destino := get_viewport().get_canvas_transform() * posicion_mundo
	etiqueta.position = destino - Vector2(12.0, 40.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(etiqueta, "position:y", etiqueta.position.y - 46.0, DURACION_DANO)
	tween.tween_property(etiqueta, "modulate:a", 0.0, DURACION_DANO)
	tween.chain().tween_callback(etiqueta.queue_free)


func _process(_delta: float) -> void:
	if is_instance_valid(_jugador):
		actualizar_cooldown(_jugador.porcentaje_cooldown())
