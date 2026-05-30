# Displays the player's 20 bag slots (inventory slots 10-29) in a 5x4 grid.
# Hidden by default. Press I to toggle open and closed.
extends Control

const SLOT_SIZE := 48
const SLOT_GAP := 4
const COLUMNS := 5
const INVENTORY_OFFSET := 10  # bag starts at slot index 10

@export var inventory: Inventory

var slots_ui: Array[InventorySlot] = []

func _ready() -> void:
	_build_panel()
	# Wait for layout to calculate the panel size before centering,
	# then hide — setting visible=false before layout gives a size of (0,0)
	await get_tree().process_frame
	_center_panel()
	visible = false
	if inventory:
		inventory.inventory_changed.connect(_refresh_slots)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		visible = !visible

func _build_panel() -> void:
	var panel := PanelContainer.new()
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Inventory"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var grid := GridContainer.new()
	grid.columns = COLUMNS
	grid.add_theme_constant_override("h_separation", SLOT_GAP)
	grid.add_theme_constant_override("v_separation", SLOT_GAP)
	vbox.add_child(grid)

	# Build the 20 bag slots
	for i in 20:
		var slot := InventorySlot.new()
		slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)

		var vbox2 := VBoxContainer.new()
		vbox2.alignment = BoxContainer.ALIGNMENT_CENTER
		slot.add_child(vbox2)

		var color_rect := ColorRect.new()
		color_rect.custom_minimum_size = Vector2(30, 30)
		color_rect.color = Color.TRANSPARENT
		vbox2.add_child(color_rect)

		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.add_theme_font_size_override("font_size", 9)
		vbox2.add_child(label)

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.15, 0.15, 0.85)
		style.set_border_width_all(2)
		style.border_color = Color(0.4, 0.4, 0.4)
		slot.add_theme_stylebox_override("panel", style)

		slot.setup(INVENTORY_OFFSET + i, inventory, color_rect, label)
		grid.add_child(slot)
		slots_ui.append(slot)

func _center_panel() -> void:
	# Use the child panel's size, not self.size — the root Control stays at (0,0)
	# and does not auto-resize to fit its children
	var panel := get_child(0)
	var vp := get_viewport().get_visible_rect().size
	position = Vector2((vp.x - panel.size.x) / 2.0, (vp.y - panel.size.y) / 2.0)

# Redraws bag slot contents to match the current inventory state
func _refresh_slots() -> void:
	for i in 20:
		slots_ui[i].refresh(inventory.get_slot(INVENTORY_OFFSET + i))
