# A single slot used by both HotbarUI and InventoryUI.
# Handles drag-and-drop so items can be moved within and between the
# hotbar and inventory. Both UIs share the same Inventory instance,
# so a swap is always just an index swap on that one array.
class_name InventorySlot
extends PanelContainer

const PREVIEW_SIZE := 36

var slot_index: int = -1
var inventory: Inventory
var color_rect: ColorRect
var label: Label

# Binds this slot to an index in the inventory after the node is created
func setup(index: int, inv: Inventory, cr: ColorRect, lbl: Label) -> void:
	slot_index = index
	inventory = inv
	color_rect = cr
	label = lbl

# Updates the slot's visual to match current inventory contents
func refresh(slot_data: Variant) -> void:
	if slot_data:
		color_rect.color = slot_data.item_data.world_color
		label.text = str(slot_data.quantity) if slot_data.quantity > 1 else ""
	else:
		color_rect.color = Color.TRANSPARENT
		label.text = ""

# Returns drag payload when the player starts dragging from this slot.
# Returns null to cancel the drag if the slot is empty.
func _get_drag_data(_at_position: Vector2) -> Variant:
	var slot_data = inventory.get_slot(slot_index)
	if slot_data == null:
		return null
	var preview := ColorRect.new()
	preview.color = slot_data.item_data.world_color
	preview.custom_minimum_size = Vector2(PREVIEW_SIZE, PREVIEW_SIZE)
	set_drag_preview(preview)
	return {index = slot_index, inventory = inventory}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not (data is Dictionary and data.has("index") and data.has("inventory")):
		return false
	# Disallow dropping onto the same slot
	return not (data.index == slot_index and data.inventory == inventory)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data.inventory.swap_slots(data.index, slot_index)
