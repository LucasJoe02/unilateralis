# Manages all of the player's item slots.
# Slots 0-9 are the hotbar; slots 10-29 are the bag.
# Listen to inventory_changed to refresh any UI that displays these slots.
class_name Inventory
extends Node

signal inventory_changed

const HOTBAR_SIZE := 10
const INVENTORY_SIZE := 20
const TOTAL_SIZE := HOTBAR_SIZE + INVENTORY_SIZE

# Each slot is null (empty) or a Dictionary {item_data: ItemData, quantity: int}
var slots: Array = []

func _ready() -> void:
	slots.resize(TOTAL_SIZE)
	slots.fill(null)

# Tries to add items, stacking onto matching slots first then filling empty ones.
# Returns true if all items were stored, false if the inventory was full.
func add_item(item_data: ItemData, quantity: int = 1) -> bool:
	var remaining := quantity

	# First pass: stack onto existing matching slots
	for i in TOTAL_SIZE:
		if remaining <= 0:
			break
		if slots[i] != null and slots[i].item_data == item_data:
			var space: int = item_data.max_stack_size - slots[i].quantity
			var to_add := mini(remaining, space)
			slots[i].quantity += to_add
			remaining -= to_add

	# Second pass: fill empty slots with any remainder
	for i in TOTAL_SIZE:
		if remaining <= 0:
			break
		if slots[i] == null:
			var to_add := mini(remaining, item_data.max_stack_size)
			slots[i] = {item_data = item_data, quantity = to_add}
			remaining -= to_add

	inventory_changed.emit()
	return remaining == 0

# Removes quantity items from the given slot, clearing it if it empties.
func remove_item(slot_index: int, quantity: int = 1) -> void:
	if slots[slot_index] == null:
		return
	slots[slot_index].quantity -= quantity
	if slots[slot_index].quantity <= 0:
		slots[slot_index] = null
	inventory_changed.emit()

func get_slot(index: int) -> Variant:
	return slots[index]

# Swaps the contents of two slots. Works for empty slots, so dragging
# onto an empty slot effectively moves the item.
func swap_slots(from_index: int, to_index: int) -> void:
	var temp = slots[from_index]
	slots[from_index] = slots[to_index]
	slots[to_index] = temp
	inventory_changed.emit()
