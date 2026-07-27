extends Node


@export var popup_root: CanvasLayer


func _ready() -> void:
	UIManager.set_root_node(popup_root)
