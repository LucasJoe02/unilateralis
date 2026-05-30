# Handles player movement, item pickup, and item use.
# Delegates inventory management to the Inventory and Hotbar child nodes.
extends CharacterBody2D

@export var speed: float = 100.0

@onready var inventory: Inventory = $Inventory
@onready var hotbar: Hotbar = $Hotbar
@onready var item_display: Polygon2D = $Hand/ItemDisplay

func _ready() -> void:
	# Refresh the hand display whenever the selected slot or inventory changes
	hotbar.selection_changed.connect(func(_i): _update_hand_display())
	inventory.inventory_changed.connect(_update_hand_display)

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

# Removes an item from the given inventory slot and spawns it as a
# WorldItem in the world, offset slightly so the player doesn't
# immediately pick it back up
func drop_item_to_world(slot_index: int) -> void:
	var slot_data = inventory.get_slot(slot_index)
	if slot_data == null:
		return
	var world_item = preload("res://scenes/world/world_item.tscn").instantiate()
	world_item.item_data = slot_data.item_data
	world_item.quantity = slot_data.quantity
	world_item.global_position = global_position + Vector2(18, 0)
	get_parent().add_child(world_item)
	inventory.remove_item(slot_index, slot_data.quantity)

# Shows a small icon of the equipped item at the hand position,
# or hides it when the selected hotbar slot is empty
func _update_hand_display() -> void:
	var slot = inventory.get_slot(hotbar.get_selected_index())
	if slot:
		item_display.color = slot.item_data.world_color
		item_display.visible = true
	else:
		item_display.visible = false
