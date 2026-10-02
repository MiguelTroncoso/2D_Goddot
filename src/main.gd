extends Node2D

## Raíz de composición offline: conecta presentación (player, enemy, HUD) con los
## sistemas (combate, IA, botín) y el dominio. No contiene reglas de juego.

const MovementInput = preload("res://src/systems/movement_input.gd")
const EnemyScene = preload("res://src/entities/enemy.tscn")

const RUTAS_MOBS := [
	"res://src/data/mobs/mordeluz_joven.tres",
	"res://src/data/mobs/mordeluz_adulto.tres",
	"res://src/data/mobs/cuervo_campana_joven.tres",
	"res://src/data/mobs/cuervo_campana_adulto.tres",
	"res://src/data/mobs/enredadera_emboscada.tres",
]
const POSICIONES_MOBS := [
	Vector2(700, 420), Vector2(1260, 760), Vector2(1420, 330),
	Vector2(560, 900), Vector2(1010, 250),
]
const SEMILLA := 7
const NIVEL_JUGADOR := 5

var _combat: CombatSystem
var _loot: LootSystem
var _ia: AiSystem
var _enemigos: Array[Node] = []
var _objetivo: Node = null
var _reloj := 0.0
var _touch_intent := Vector2.ZERO

@onready var player = $World/Player
@onready var joystick = $UI/HUD/VirtualJoystick
@onready var hud = $UI/HUD
@onready var combat_hud = $UI/HUD/CombatHUD


func _ready() -> void:
	joystick.movement_changed.connect(_on_touch_movement_changed)
	hud.configurar_jugador(player)
	player.get_node("Camera2D").reset_smoothing()
	_combat = CombatSystem.new(SEMILLA)
	_loot = LootSystem.new(SEMILLA)
	_ia = AiSystem.new()
	_combat.registrar_actor(&"jugador", &"jugador", StatBlock.base(NIVEL_JUGADOR), player.vida_max)
	_combat.dano_aplicado.connect(_on_dano_aplicado)
	_combat.actor_derrotado.connect(_on_derrotado)
	player.ataque_solicitado.connect(_on_ataque_jugador)
	combat_hud.configurar(player)
	combat_hud.ataque_presionado.connect(func() -> void: player.intentar_ataque())
	_spawnear_enemigos()


func _physics_process(delta: float) -> void:
	_reloj += delta
	var keyboard := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.movement_intent = MovementInput.combine(keyboard, _touch_intent)
	_actualizar_objetivo()


func _spawnear_enemigos() -> void:
	for indice in RUTAS_MOBS.size():
		var definicion: MobDefinition = load(RUTAS_MOBS[indice])
		if definicion == null:
			continue
		var enemigo := EnemyScene.instantiate()
		enemigo.configurar(definicion, _ia, player)
		enemigo.position = POSICIONES_MOBS[indice % POSICIONES_MOBS.size()]
		enemigo.intento_ataque.connect(_on_enemigo_ataca)
		$World.add_child(enemigo)
		_enemigos.append(enemigo)
		_combat.registrar_actor(
			_id_de(enemigo), &"enemigo", definicion.arquetipo().stat_block(), enemigo.vida_max
		)


func _actualizar_objetivo() -> void:
	if is_instance_valid(_objetivo) and not _objetivo.esta_vivo():
		_objetivo = null
	if not is_instance_valid(_objetivo):
		_objetivo = null
		for cuerpo in player.objetivos_en_rango():
			if cuerpo.has_method("esta_vivo") and cuerpo.esta_vivo():
				_objetivo = cuerpo
				break
	if is_instance_valid(_objetivo):
		combat_hud.mostrar_enemigo(_objetivo.definicion.nombre, _objetivo.vida, _objetivo.vida_max)
	else:
		combat_hud.limpiar_enemigo()


func _on_ataque_jugador() -> void:
	for cuerpo in player.objetivos_en_rango():
		if not cuerpo.has_method("esta_vivo") or not cuerpo.esta_vivo():
			continue
		_combat.atacar(&"jugador", _id_de(cuerpo), {
			"habilidad": &"basico",
			"coef": player.coef_ataque,
			"tipo": DamageTypes.FISICO,
			"ignorar_cooldown": true,
		}, _reloj)


func _on_enemigo_ataca(enemigo: Node) -> void:
	if not is_instance_valid(enemigo) or not enemigo.esta_vivo():
		return
	_combat.atacar(_id_de(enemigo), &"jugador", {
		"habilidad": &"mordida",
		"coef": enemigo.definicion.coef_ataque,
		"tipo": enemigo.arquetipo.tipo_dano,
		"ignorar_cooldown": true,
	}, _reloj)


func _on_dano_aplicado(evento: Dictionary) -> void:
	var objetivo: StringName = evento["objetivo"]
	if objetivo == &"jugador":
		player.recibir_dano(float(evento["dano"]))
		return
	var enemigo := _buscar_enemigo(objetivo)
	if enemigo == null:
		return
	enemigo.recibir_dano(float(evento["dano"]))
	combat_hud.mostrar_dano(
		int(evento["dano_entero"]), enemigo.global_position, bool(evento["es_critico"])
	)


func _on_derrotado(evento: Dictionary) -> void:
	var objetivo: StringName = evento["objetivo"]
	if objetivo == &"jugador":
		return
	var enemigo := _buscar_enemigo(objetivo)
	if enemigo == null:
		return
	var arquetipo: EnemyArchetype = enemigo.arquetipo
	_loot.generar_botin(arquetipo, enemigo.definicion.botin)
	_loot.generar_cobre(arquetipo)
	var recompensa := _loot.otorgar_xp(arquetipo, NIVEL_JUGADOR)
	combat_hud.mostrar_dano(
		int(recompensa["xp"]), enemigo.global_position + Vector2(0, -30), true
	)
	_enemigos.erase(enemigo)
	_combat.desregistrar_actor(objetivo)
	if _objetivo == enemigo:
		_objetivo = null
	enemigo.morir()


func _buscar_enemigo(id: StringName) -> Node:
	for enemigo in _enemigos:
		if is_instance_valid(enemigo) and _id_de(enemigo) == id:
			return enemigo
	return null


func _id_de(nodo: Node) -> StringName:
	return StringName(str(nodo.get_instance_id()))


func _on_touch_movement_changed(direction: Vector2) -> void:
	_touch_intent = direction


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		_touch_intent = Vector2.ZERO
		for action in [&"move_left", &"move_right", &"move_up", &"move_down"]:
			Input.action_release(action)
		if is_instance_valid(player):
			player.movement_intent = Vector2.ZERO
