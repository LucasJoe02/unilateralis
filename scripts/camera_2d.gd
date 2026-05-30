extends Camera2D

@export var follow_speed: float = 5.0
@export var target: Node2D 

func _physics_process(delta: float) -> void:
	if target:
		global_position = global_position.lerp(target.global_position, follow_speed * delta)


func _on_world_item_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
