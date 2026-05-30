# A single slot used by both HotbarUI and InventoryUI.
# Handles drag-and-drop so items can be moved within and between the
# hotbar and inventory. Both UIs share the same Inventory instance,
# so a swap is always just an index swap on that one array.
# Dragging an item outside any valid slot drops it back into the world.
class_name InventorySlot
extends PanelContainer

const PREVIEW_SIZE := 36

var slot_index: int = -1
var inventory: Inventory
var color_rect: ColorRect
var label: Label
var drag_enabled: bool = true

# Tracks which slot started the current drag so NOTIFICATION_DRAG_END
# can tell whether this slot is the one that needs to act on a failed drop
static var dragging_slot: InventorySlot = null

# Binds this slot to an index in the inventory after the node is created
func setup(index: int, inv: Inventory, cr: ColorRect, lbl: Label) -> void:
	slot_index = index
	inventory = inv
	color_rect = cr
	label = lbl
	# Child nodes default to MOUSE_FILTER_STOP which blocks mouse events from
	# reaching this slot. Set them all to IGNORE so drag events hit the slot.
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if cr.get_parent() is Control:
		cr.get_parent().mouse_filter = Control.MOUSE_FILTER_IGNORE

# Updates the slot's visual to match current inventory contents
func refresh(slot_data: Variant) -> void:
	if slot_data:
		color_rect.color = slot_data.item_data.world_color
		label.text = str(slot_data.quantity) if slot_data.quantity > 1 else ""
	else:
		color_rect.color = Color.TRANSPARENT
		label.text = ""

# Returns drag payload when the player starts dragging from this slot.
# Returns null to cancel the drag if the slot is empty or drag is disabled.
func _get_drag_data(_at_position: Vector2) -> Variant:
	if not drag_enabled:
		return null
	var slot_data = inventory.get_slot(slot_index)
	if slot_data == null:
		return null
	InventorySlot.dragging_slot = self
	var preview := ColorRect.new()
	preview.color = slot_data.item_data.world_color
	preview.custom_minimum_size = Vector2(PREVIEW_SIZE, PREVIEW_SIZE)
	set_drag_preview(preview)
	return {index = slot_index, inventory = inventory}

# Accept same-slot drops so dragging back to the origin is treated as
# successful (no-op), rather than triggering a world drop
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("index") and data.has("inventory")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	# Same slot — nothing to do
	if data.index == slot_index and data.inventory == inventory:
		return
	data.inventory.swap_slots(data.index, slot_index)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		# Only the slot that started the drag should handle a failed drop
		if InventorySlot.dragging_slot != self:
			return
		var successful := get_viewport().gui_is_drag_successful()
		InventorySlot.dragging_slot = null
		if not successful:
			_drop_to_world()

# Removes the item from inventory and asks the player to spawn it in the world
func _drop_to_world() -> void:
	var slot_data = inventory.get_slot(slot_index)
	if slot_data == null:
		return
	var player = inventory.get_parent()
	if player.has_method("drop_item_to_world"):
		player.drop_item_to_world(slot_index)
