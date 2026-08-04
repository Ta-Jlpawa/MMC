extends Control
class_name ModObject


@export var title_label: RichTextLabel
@export var author_label: Label
@export var content_label: RichTextLabel
@export var mcver_label: Label
@export var modver_label: Label


func set_data(title: String, author: String, content: String, mc_version: String, mod_version: String) -> void:
	title_label.text = title
	author_label.text = author
	content_label.text = content
	mcver_label.text = mc_version
	modver_label.text = mod_version
