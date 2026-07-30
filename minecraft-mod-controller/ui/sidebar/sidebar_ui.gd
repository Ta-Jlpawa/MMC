extends PanelContainer
class_name SideBarUI

signal option_selected(index: int)

@export var all_button: Array[BaseButton] = []

var button_group: ButtonGroup
var pressed_button: BaseButton


func _ready() -> void:
	button_group = ButtonGroup.new()
	for i in all_button:
		i.button_group = button_group
	pressed_button = button_group.get_pressed_button()
	button_group.pressed.connect(_on_button_pressed)


## 按钮组中有按钮被按下时触发
func _on_button_pressed(button: BaseButton):
	if pressed_button == button: return
	pressed_button = button
	var index: int = all_button.find(button)
	option_selected.emit(index)
