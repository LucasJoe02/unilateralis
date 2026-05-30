# Represents a physical item sitting in the world that the player can walk over to pick up.
# Set item_data in the Inspector to define which item this is.
# Emits picked_up when a player body enters, then removes itself from the scene.
class_name WorldItem
extends Area2D

@export var item_data: ItemData
@export var quantity: int = 1

signal picked_up(item_data: ItemData, quantity: int)

func _ready() -> void:
	# Apply the item's colour to the placeholder visual
	if item_data:
		$Body.color = item_data.world_color

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		picked_up.emit(item_data, quantity)
		queue_free()
