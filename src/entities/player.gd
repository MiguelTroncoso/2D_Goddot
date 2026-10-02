extends CharacterBody2D

## Presentación del jugador. La lógica de daño vive en `systems/combat_system.gd`;
## este script solo aplica movimiento, pide ataques y muestra feedback.

signal ataque_solicitado

@export_range(1.0, 1000.0, 1.0) var movement_speed: float = 240.0
@export_range(0.1, 10.0, 0.1) var cooldown_ataque: float = 1.0
@export_range(0.1, 5.0, 0.1) var coef_ataque: float = 1.0
@export var vida_max: float = 100.0

var movement_intent := Vector2.ZERO
var vida: float = 100.0

var _tiempo := 0.0
var _ultimo_ataque := -99.0
var _flash := 0.0
@onready var _cuerpo: Polygon2D = get_node_or_null("Body")
@onready var _area_ataque: Area2D = get_node_or_null("AtaqueArea")


func puede_atacar() -> bool:
	return _tiempo - _ultimo_ataque >= cooldown_ataque


## Pide un ataque. El daño lo resuelve `CombatSystem` desde la composición.
func intentar_ataque() -> bool:
	if not puede_atacar():
		return false
	_ultimo_ataque = _tiempo
	_flash = 0.15
	ataque_solicitado.emit()
	return true


func porcentaje_cooldown() -> float:
	if cooldown_ataque <= 0.0:
		return 1.0
	return clampf((_tiempo - _ultimo_ataque) / cooldown_ataque, 0.0, 1.0)


func recibir_dano(cantidad: float) -> void:
	vida = maxf(0.0, vida - maxf(0.0, cantidad))
	_flash = 0.2


func porcentaje_vida() -> float:
	return 0.0 if vida_max <= 0.0 else clampf(vida / vida_max, 0.0, 1.0)


## Cuerpos enemigos dentro de la hitbox de ataque (Area2D, capa 4).
func objetivos_en_rango() -> Array:
	if _area_ataque == null:
		return []
	return _area_ataque.get_overlapping_bodies()


func _physics_process(delta: float) -> void:
	_tiempo += delta
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta)
	if _cuerpo != null:
		_cuerpo.modulate = Color(1.5, 1.5, 0.9) if _flash > 0.0 else Color.WHITE
	velocity = movement_intent.limit_length(1.0) * movement_speed
	# CharacterBody2D integrates velocity using the physics timestep itself.
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		intentar_ataque()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# En escritorio, el clic en la mitad derecha ataca (la izquierda es el joystick).
		var ancho := get_viewport().get_visible_rect().size.x
		if event.position.x > ancho * 0.5:
			intentar_ataque()
