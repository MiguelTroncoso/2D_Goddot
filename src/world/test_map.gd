extends Node2D
## Original geometric placeholders; collision geometry lives in the scene.


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1920, 1280), Color(0.15, 0.23, 0.24))
	for x in range(0, 1921, 64):
		draw_line(Vector2(x, 0), Vector2(x, 1280), Color(0.18, 0.27, 0.27))
	for y in range(0, 1281, 64):
		draw_line(Vector2(0, y), Vector2(1920, y), Color(0.18, 0.27, 0.27))
	# Spawn marker is decorative; it has no gameplay or collision behavior.
	draw_arc(Vector2(960, 640), 56.0, 0.0, TAU, 48, Color(0.35, 0.55, 0.49), 2.0)
