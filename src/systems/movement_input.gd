extends RefCounted
## Pure input math shared by the desktop and touch control paths.


static func combine(keyboard: Vector2, touch: Vector2) -> Vector2:
	return (keyboard + touch).limit_length(1.0)


static func joystick_vector(offset: Vector2, travel: float, dead_zone: float) -> Vector2:
	if travel <= 0.0:
		return Vector2.ZERO
	var raw := (offset / travel).limit_length(1.0)
	var magnitude := raw.length()
	var threshold := clampf(dead_zone, 0.0, 0.99)
	if magnitude <= threshold:
		return Vector2.ZERO
	# Rescale outside the dead zone so slow movement remains possible.
	return raw.normalized() * ((magnitude - threshold) / (1.0 - threshold))
