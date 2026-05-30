# Base resource that defines the shared properties every item has.
# Create a new .tres file using this (or a subclass) for each item type —
# no code changes needed to add new items.
class_name ItemData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var max_stack_size: int = 1

# Tint used for the item's placeholder polygon in the world.
# Replace with a proper sprite/icon once art is available.
@export var world_color: Color = Color.WHITE

# Called when a character uses this item from their hotbar.
# Override in subclasses to implement item-specific behaviour.
func use(user: Node2D) -> void:
	pass
