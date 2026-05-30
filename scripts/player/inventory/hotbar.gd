# Tracks which hotbar slot is currently selected.
# Handles scroll wheel input to cycle through the 10 slots.
class_name Hotbar
extends Node

signal selection_changed(index: int)

const SIZE := 10

var selected_index: int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_item"):
		selected_index = (selected_index + 1) % SIZE
		selection_changed.emit(selected_index)
	elif event.is_action_pressed("prev_item"):
		selected_index = (selected_index - 1 + SIZE) % SIZE
		selection_changed.emit(selected_index)

func get_selected_index() -> int:
	return selected_index
