extends CharacterBody2D

## Presentación de una criatura (TASK-004). No decide nada: pide la decisión al
## dominio (`AiPatterns` vía `AiSystem`) y la aplica al movimiento.
## Los ataques se anuncian por señal y los resuelve `CombatSystem` desde `main.gd`.

signal intento_ataque(enemigo)
signal derrotado(enemigo)

@export var definicion: MobDefinition

var arquetipo: EnemyArchetype
var sistema_ia: AiSystem
var objetivo: Node2D
var vida: float = 1.0
var vida_max: float = 1.0
var en_combate := false
var tiempo := 0.0
var ultimo_ataque := -99.0
var ultima_decision: Dictionary = {}

var _cuerpo: Polygon2D
var _flash := 0.0


func configurar(nueva_definicion: MobDefinition, ia: AiSystem, jugador: Node2D) -> void:
	definicion = nueva_definicion
	arquetipo = definicion.arquetipo()
	sistema_ia = ia
	objetivo = jugador
	vida_max = arquetipo.vida()
	vida = vida_max
	collision_layer = 4
	collision_mask = 1
	_cuerpo = get_node_or_null("Cuerpo")
	if _cuerpo != null:
		_cuerpo.color = definicion.color_placeholder
	position = definicion.get_meta("posicion") if definicion.has_meta("posicion") else position
	scale = Vector2.ONE * definicion.escala


func recibir_dano(cantidad: float) -> void:
	vida = maxf(0.0, vida - maxf(0.0, cantidad))
	en_combate = true
	_flash = 0.15


func esta_vivo() -> bool:
	return vida > 0.0


func porcentaje_vida() -> float:
	return 0.0 if vida_max <= 0.0 else clampf(vida / vida_max, 0.0, 1.0)


func _physics_process(delta: float) -> void:
	if arquetipo == null or sistema_ia == null:
		return
	tiempo += delta
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta)
	if _cuerpo != null:
		_cuerpo.modulate = Color(1.6, 0.7, 0.7) if _flash > 0.0 else Color.WHITE
	if not esta_vivo():
		velocity = Vector2.ZERO
		return
	var distancia := INF
	var objetivo_valido: bool = is_instance_valid(objetivo) and float(objetivo.get("vida")) > 0.0
	if is_instance_valid(objetivo):
		distancia = global_position.distance_to(objetivo.global_position)
	ultima_decision = sistema_ia.decidir(StringName(str(get_instance_id())), arquetipo.patron_ia, {
		"distancia": distancia,
		"vida_pct": porcentaje_vida(),
		"objetivo_valido": objetivo_valido,
		"en_combate": en_combate,
		"radio_deteccion": arquetipo.radio_deteccion,
		"radio_agarre": arquetipo.radio_agarre,
		"radio_ataque": arquetipo.radio_ataque,
		"tiempo": tiempo,
		"posicion_actual": global_position,
		"posicion_objetivo": objetivo.global_position if is_instance_valid(objetivo) else Vector2.ZERO,
		"posicion_guardia": global_position,
	})
	var direccion: Vector2 = ultima_decision.get("mover_hacia", Vector2.ZERO)
	velocity = direccion * arquetipo.velocidad
	move_and_slide()
	if bool(ultima_decision.get("atacar", false)) and tiempo - ultimo_ataque >= definicion.cooldown_ataque:
		ultimo_ataque = tiempo
		intento_ataque.emit(self)


func morir() -> void:
	derrotado.emit(self)
	queue_free()
