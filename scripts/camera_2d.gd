# Smoothly follows a target node by lerping toward its position each frame.
# Assign the target in the Inspector or via code before the camera is used.
extends Camera2D

@export var follow_speed: float = 5.0
@export var target: Node2D

func _physics_process(delta: float) -> void:
	if target:
		global_position = global_position.lerp(target.global_position, follow_speed * delta)
