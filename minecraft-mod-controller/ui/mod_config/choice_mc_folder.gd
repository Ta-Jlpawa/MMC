extends TextureRect

signal choice_mc_folder_pressed()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			choice_mc_folder_pressed.emit()
