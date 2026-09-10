extends SceneTree
## Native Phase 1 tests. Any failed expectation exits nonzero, even in release builds.

const MovementInput = preload("res://src/systems/movement_input.gd")
const MainScene = preload("res://src/main.tscn")
var _checks := 0
var _failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _expect(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("FAIL: " + description)
	else:
		print("PASS: " + description)


func _run() -> void:
	_test_input_math()
	await _test_playable_scene()
	print("PHASE1_TEST_RESULT: %d checks, %d failures" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)


func _test_input_math() -> void:
	_expect(MovementInput.combine(Vector2.ZERO, Vector2.ZERO) == Vector2.ZERO, "idle input")
	for direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		_expect(MovementInput.combine(direction, Vector2.ZERO) == direction, "cardinal input %s" % direction)
	_expect(is_equal_approx(MovementInput.combine(Vector2.ONE, Vector2.ZERO).length(), 1.0), "diagonal speed is normalized")
	_expect(is_equal_approx(MovementInput.combine(Vector2.RIGHT, Vector2.DOWN).length(), 1.0), "keyboard plus touch cannot double speed")
	_expect(MovementInput.combine(Vector2.RIGHT, Vector2.LEFT) == Vector2.ZERO, "opposing input cancels")
	_expect(MovementInput.combine(Vector2.ZERO, Vector2(0.25, 0)) == Vector2(0.25, 0), "analog input preserves slow speed")
	_expect(MovementInput.joystick_vector(Vector2.ZERO, 64, 0.15) == Vector2.ZERO, "joystick center has no drift")
	_expect(MovementInput.joystick_vector(Vector2(8, 0), 64, 0.15) == Vector2.ZERO, "joystick dead zone")
	_expect(MovementInput.joystick_vector(Vector2(9.6, 0), 64, 0.15).is_zero_approx(), "dead zone boundary")
	_expect(MovementInput.joystick_vector(Vector2(64, 0), 64, 0.15).is_equal_approx(Vector2.RIGHT), "full joystick travel")
	_expect(is_equal_approx(MovementInput.joystick_vector(Vector2(400, 400), 64, 0.15).length(), 1.0), "outside drag is clamped")
	_expect(MovementInput.joystick_vector(Vector2(32, 0), 64, 0.0).is_equal_approx(Vector2(0.5, 0)), "zero dead zone preserves analog magnitude")
	_expect(MovementInput.joystick_vector(Vector2.ONE, 0, 0.15) == Vector2.ZERO, "zero travel is safe")
	var just_outside := MovementInput.joystick_vector(Vector2(10, 0), 64, 0.15)
	_expect(just_outside.length() > 0 and just_outside.length() < 0.02, "dead zone has no sudden speed jump")


func _test_playable_scene() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	current_scene = main
	await process_frame
	var player = main.get_node("World/Player")
	var joystick = main.get_node("UI/HUD/VirtualJoystick")
	var camera: Camera2D = player.get_node("Camera2D")
	_expect(player is CharacterBody2D, "playable player uses CharacterBody2D")
	_expect(camera.is_current(), "player camera is active")
	_expect(main.get_node("UI/HUD/HealthPanel/HealthPlaceholder").value == 100, "HUD shows fixed health placeholder")
	_expect(ProjectSettings.get_setting("display/window/handheld/orientation") == DisplayServer.SCREEN_LANDSCAPE, "landscape orientation remains configured")
	for action in [&"move_up", &"move_down", &"move_left", &"move_right"]:
		_expect(InputMap.has_action(action) and InputMap.action_get_events(action).size() == 2, "keyboard bindings for %s" % action)

	# Compare real movement over one second at two physics rates.
	var saved_ticks := Engine.physics_ticks_per_second
	var distances: Array[float] = []
	for ticks in [30, 60]:
		Engine.physics_ticks_per_second = ticks
		player.position = Vector2(960, 640)
		await _physics_steps(2)
		var start: Vector2 = player.position
		Input.action_press("move_right")
		await _physics_steps(ticks)
		Input.action_release("move_right")
		distances.append(player.position.distance_to(start))
		_expect(absf(distances[-1] - player.movement_speed) < 0.5, "one-second movement at %d physics ticks" % ticks)
	Engine.physics_ticks_per_second = saved_ticks
	_expect(absf(distances[0] - distances[1]) < 0.5, "speed independent of physics tick rate")
	await _physics_steps(2)
	_expect(player.velocity.is_zero_approx(), "keyboard release stops movement")
	player.position = Vector2(960, 640)
	_key(KEY_W, true)
	_key(KEY_RIGHT, true)
	await _physics_steps(2)
	_expect(player.velocity.x > 0 and player.velocity.y < 0, "W and arrow physical keys drive real movement")
	_expect(is_equal_approx(player.velocity.length(), player.movement_speed), "real diagonal velocity stays at movement speed")
	_key(KEY_W, false)
	_key(KEY_RIGHT, false)
	await _physics_steps(2)
	player.position = Vector2(1056, 400)
	Input.action_press("move_up")
	await _physics_steps(30)
	Input.action_release("move_up")
	_expect(player.position.y >= 369.9 and player.position.y < 375, "move_and_slide stops against environment while input is held")

	# Exercise each real environment collider with the configured player shape.
	for obstacle in main.get_node("World/TestMap").get_children():
		if not obstacle is StaticBody2D:
			continue
		var half_size: Vector2 = obstacle.get_node("CollisionShape2D").shape.size * 0.5
		var approach := Vector2.RIGHT
		if obstacle.name == "EastWall":
			approach = Vector2.LEFT
		elif obstacle.name == "NorthWall":
			approach = Vector2.DOWN
		elif obstacle.name == "SouthWall":
			approach = Vector2.UP
		player.position = obstacle.position + approach * (half_size + Vector2(40, 40))
		await _physics_steps(1)
		var hit = player.move_and_collide(-approach * 100)
		_expect(hit != null and hit.get_collider() == obstacle, "collision blocks %s" % obstacle.name)

	# Touch goes through the viewport input route, signal connection and physics movement.
	player.position = Vector2(960, 640)
	await _physics_steps(2)
	var center: Vector2 = joystick.get_global_transform_with_canvas() * (joystick.size * 0.5)
	_touch(3, center, true)
	_drag(3, center + Vector2(64, 0))
	await _physics_steps(2)
	_expect(joystick.output.is_equal_approx(Vector2.RIGHT), "touch drag produces movement vector")
	_expect(player.position.x > 960 and player.velocity.x > 0, "touch moves the player via common intent")
	_touch(4, center - Vector2(64, 0), true)
	_drag(4, center - Vector2(64, 0))
	_touch(4, center, false)
	_expect(joystick.output.is_equal_approx(Vector2.RIGHT), "second finger cannot steal or release joystick")
	_drag(3, center + Vector2(500, 500))
	_expect(is_equal_approx(joystick.output.length(), 1.0), "touch drag outside control remains clamped")
	_touch(3, center + Vector2(500, 500), false)
	await _physics_steps(2)
	_expect(joystick.output == Vector2.ZERO and player.velocity.is_zero_approx(), "release outside control stops player and centers joystick")
	_touch(5, center, true)
	_drag(5, center + Vector2(64, 0))
	_touch(5, center, false, true)
	_expect(joystick.output == Vector2.ZERO, "canceled touch resets joystick")
	_touch(6, center, true)
	_drag(6, center + Vector2(64, 0))
	Input.action_press("move_up")
	main.propagate_notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await _physics_steps(2)
	_expect(joystick.output == Vector2.ZERO and player.velocity.is_zero_approx(), "focus loss releases keyboard and touch")
	_touch(7, center, true)
	_drag(7, center + Vector2(64, 0))
	joystick.hide()
	_expect(joystick.output == Vector2.ZERO, "hiding joystick releases touch")
	joystick.show()
	_touch(8, center + Vector2(200, 0), true)
	_drag(8, center)
	_expect(joystick.output == Vector2.ZERO, "touch must start inside joystick")
	_touch(8, center, false)

	player.position = Vector2(960, 640)
	camera.reset_smoothing()
	await _physics_steps(2)
	var camera_start := camera.get_screen_center_position()
	Input.action_press("move_right")
	await _physics_steps(20)
	Input.action_release("move_right")
	await _physics_steps(30)
	_expect(camera.get_screen_center_position().x > camera_start.x + 40, "camera follows player movement")
	main.queue_free()
	await process_frame


func _physics_steps(count: int) -> void:
	# Resume after the frame's physics callbacks, not before them.
	for step in count:
		await physics_frame
		await process_frame


func _touch(index: int, position: Vector2, pressed: bool, canceled: bool = false) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	event.canceled = canceled
	root.push_input(event, true)


func _drag(index: int, position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position
	root.push_input(event, true)


func _key(physical_key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = physical_key
	event.pressed = pressed
	Input.parse_input_event(event)
