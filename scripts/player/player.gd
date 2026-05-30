# Handles player movement input and physics.
# Reads WASD/arrow key input each physics frame and moves the character accordingly.
extends CharacterBody2D

@export var speed: float = 100.0

func _physics_process(_delta: float) -> void:
	# Build a normalised direction vector from the four movement actions
	var direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

	velocity = direction * speed
	move_and_slide()
