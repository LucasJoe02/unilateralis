# Smoothly follows a target node by lerping toward its position each frame.
# Snaps to the target once close enough to prevent wobble as the camera settles.
# Assign the target in the Inspector or via code before the camera is used.
extends Camera2D

@export var follow_speed: float = 5.0
@export var snap_distance: float = 0.5
@export var target: Node2D

func _physics_process(delta: float) -> void:
	if target:
		# Snap directly to the target when close enough to prevent lerp wobble
		if global_position.distance_to(target.global_position) < snap_distance:
			global_position = target.global_position
		else:
			global_position = global_position.lerp(target.global_position, follow_speed * delta)
