# Handles player movement, item pickup, and item use.
# Delegates inventory management to the Inventory and Hotbar child nodes.
extends CharacterBody2D

@export var speed: float = 100.0

@onready var inventory: Inventory = $Inventory
@onready var hotbar: Hotbar = $Hotbar

func _physics_process(_delta: float) -> void:
	# Build a normalised direction vector from the four movement actions
	var direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	velocity = direction * speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	# Use the currently equipped item on primary action.
	# _unhandled_input ensures clicks consumed by UI slots don't also fire this.
	if event.is_action_pressed("primary_action"):
		var slot = inventory.get_slot(hotbar.get_selected_index())
		if slot:
			print("Used: ", slot.item_data.display_name)
			slot.item_data.use(self)

# Called by WorldItem when the player walks over a pickup
func pickup_item(item_data: ItemData, quantity: int) -> void:
	inventory.add_item(item_data, quantity)
