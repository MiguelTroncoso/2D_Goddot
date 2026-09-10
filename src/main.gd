extends Node2D
## Scene composition only: input providers share a single player movement intent.

const MovementInput = preload("res://src/systems/movement_input.gd")
var _touch_intent := Vector2.ZERO
@onready var player = $World/Player
@onready var joystick = $UI/HUD/VirtualJoystick


func _ready() -> void:
	joystick.movement_changed.connect(_on_touch_movement_changed)
	player.get_node("Camera2D").reset_smoothing()


func _physics_process(_delta: float) -> void:
	var keyboard := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.movement_intent = MovementInput.combine(keyboard, _touch_intent)


func _on_touch_movement_changed(direction: Vector2) -> void:
	_touch_intent = direction


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		_touch_intent = Vector2.ZERO
		for action in [&"move_left", &"move_right", &"move_up", &"move_down"]:
			Input.action_release(action)
		if is_instance_valid(player):
			player.movement_intent = Vector2.ZERO
