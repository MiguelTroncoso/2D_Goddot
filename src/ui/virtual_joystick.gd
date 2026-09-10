extends Control
## Fixed, single-finger joystick. Mouse testing uses Godot's touch emulation.

signal movement_changed(direction: Vector2)

const MovementInput = preload("res://src/systems/movement_input.gd")
const BASE_RADIUS := 100.0
const KNOB_RADIUS := 36.0
const TRAVEL := BASE_RADIUS - KNOB_RADIUS
@export_range(0.0, 0.9, 0.01) var dead_zone: float = 0.15
var output := Vector2.ZERO
var _finger: int = -1
var _knob_offset := Vector2.ZERO


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	resized.connect(reset)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		if event.index == _finger and (not event.pressed or event.canceled):
			reset()
			get_viewport().set_input_as_handled()
		elif event.pressed and not event.canceled and _finger == -1:
			var offset := _local_offset(event.position)
			if offset.length() <= BASE_RADIUS:
				_finger = event.index
				_update_output(offset)
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == _finger and _finger != -1:
		_update_output(_local_offset(event.position))
		get_viewport().set_input_as_handled()


func _local_offset(viewport_position: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * viewport_position - size * 0.5


func _update_output(offset: Vector2) -> void:
	_knob_offset = offset.limit_length(TRAVEL)
	output = MovementInput.joystick_vector(offset, TRAVEL, dead_zone)
	movement_changed.emit(output)
	queue_redraw()


func reset() -> void:
	_finger = -1
	_knob_offset = Vector2.ZERO
	output = Vector2.ZERO
	movement_changed.emit(output)
	queue_redraw()


func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		reset()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		reset()


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, BASE_RADIUS, Color(0.07, 0.13, 0.17, 0.82))
	draw_arc(center, BASE_RADIUS, 0.0, TAU, 64, Color(0.49, 0.68, 0.69, 0.8), 2.0, true)
	draw_line(center - Vector2(14, 0), center + Vector2(14, 0), Color(0.5, 0.7, 0.7, 0.4), 2.0)
	draw_line(center - Vector2(0, 14), center + Vector2(0, 14), Color(0.5, 0.7, 0.7, 0.4), 2.0)
	draw_circle(center + _knob_offset, KNOB_RADIUS, Color(0.45, 0.85, 0.78, 0.95))
