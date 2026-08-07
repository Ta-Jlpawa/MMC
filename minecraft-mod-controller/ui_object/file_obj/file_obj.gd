extends Control
class_name FileObj


@export var button: Button
@export var file_name_label: Label
@export var file_path_label: Label

var id: int = 0


func set_data(file_name: String, file_path: String, button_id: int):
	id = button_id
	file_name_label.text = file_name
	file_path_label.text = file_path


func is_pressed() -> bool:
	return button.button_pressed
