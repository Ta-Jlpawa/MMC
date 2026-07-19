extends Node

var popup_root: CanvasLayer = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup_root = get_tree().current_scene.popup_root


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func show_warning_popup(warn_type: GameConfig.WarningType, content: String) -> void:
	var scene: PackedScene = load("res://ui/popup/WarningPopup/warning_popup.tscn")
	var popup: WarningPopup = scene.instantiate()
	popup.set_popup_data(warn_type, content)
	popup.anchor_left = 0.5
	popup.anchor_right = 0.5
	popup.anchor_top = 0.5
	popup.anchor_bottom = 0.5
	var texture_size = popup.get_size()
	popup.offset_left = -texture_size.x / 2
	popup.offset_right = texture_size.x / 2
	popup.offset_top = -texture_size.y / 2
	popup.offset_bottom = texture_size.y / 2
	popup_root.add_child(popup)
