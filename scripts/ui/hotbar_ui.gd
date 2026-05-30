# Displays the 10 hotbar slots at the bottom of the screen.
# Slots are built procedurally at runtime. Shows item colour and stack count.
# The selected slot is highlighted with a yellow border.
extends Control

const SLOT_SIZE := 48
const SLOT_GAP := 4
const HOTBAR_SIZE := 10

@export var inventory: Inventory
@export var hotbar: Hotbar

# Parallel array of slot UI references: {panel, color_rect, label}
var slots_ui: Array = []

func _ready() -> void:
	_build_slots()
	# Wait one frame so the container has calculated its size before positioning
	await get_tree().process_frame
	_position_at_bottom()
	if inventory:
		inventory.inventory_changed.connect(_refresh_slots)
	if hotbar:
		hotbar.selection_changed.connect(func(_i): _refresh_selection())
	_refresh_selection()

func _build_slots() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", SLOT_GAP)
	add_child(row)

	for i in HOTBAR_SIZE:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)

		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		panel.add_child(vbox)

		var color_rect := ColorRect.new()
		color_rect.custom_minimum_size = Vector2(30, 30)
		color_rect.color = Color.TRANSPARENT
		vbox.add_child(color_rect)

		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.add_theme_font_size_override("font_size", 9)
		vbox.add_child(label)

		row.add_child(panel)
		slots_ui.append({panel = panel, color_rect = color_rect, label = label})

func _position_at_bottom() -> void:
	# Use the child row's size, not self.size — the root Control stays at (0,0)
	# and does not auto-resize to fit its children
	var row := get_child(0)
	var vp := get_viewport().get_visible_rect().size
	position = Vector2((vp.x - row.size.x) / 2.0, vp.y - row.size.y - 4.0)

# Redraws slot contents to match the current inventory state
func _refresh_slots() -> void:
	for i in HOTBAR_SIZE:
		var slot = inventory.get_slot(i)
		var ui: Dictionary = slots_ui[i]
		if slot:
			ui.color_rect.color = slot.item_data.world_color
			ui.label.text = str(slot.quantity) if slot.quantity > 1 else ""
		else:
			ui.color_rect.color = Color.TRANSPARENT
			ui.label.text = ""

# Redraws slot borders to reflect the current selection
func _refresh_selection() -> void:
	for i in HOTBAR_SIZE:
		var selected := i == hotbar.get_selected_index()
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.15, 0.15, 0.85)
		style.set_border_width_all(2)
		style.border_color = Color(1.0, 0.85, 0.0) if selected else Color(0.4, 0.4, 0.4)
		slots_ui[i].panel.add_theme_stylebox_override("panel", style)
