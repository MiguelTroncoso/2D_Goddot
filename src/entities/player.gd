extends CharacterBody2D

@export_range(1.0, 1000.0, 1.0) var movement_speed: float = 240.0
var movement_intent := Vector2.ZERO


func _physics_process(_delta: float) -> void:
	velocity = movement_intent.limit_length(1.0) * movement_speed
	# CharacterBody2D integrates velocity using the physics timestep itself.
	move_and_slide()
