extends Control
class_name ModConfigObject


@export var title_label: RichTextLabel
@export var content_label: RichTextLabel
@export var mcver_label: Label
@export var modver_label: Label


func set_data(title: String, content: String, mc_version: String, modloader_version: String) -> void:
	title_label.text = title
	content_label.text = content
	mcver_label.text = mc_version
	modver_label.text = modloader_version
