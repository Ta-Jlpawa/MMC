extends Button
## 使用富文本显示文本的单选按钮，代价是没有引擎自带的依据按钮状态来使文本变色
class_name RichCheckButton


@export_multiline() var true_text: String = "按钮文本"
@export_multiline() var false_text: String = "按钮文本"
@export var default_state: bool = true

@onready var richTextLabel: RichTextLabel = $RichTextLabel


func _ready() -> void:
	reset()
	self.toggled.connect(_on_button_toggled)


func get_state() -> bool:
	return !self.button_pressed


## 重置按钮设定的初始状态
func reset() -> void:
	self.button_pressed = !default_state
	if default_state:
		richTextLabel.text = true_text
	else:
		richTextLabel.text = false_text
	

func _on_button_toggled(state: bool) -> void:
	if !state:
		richTextLabel.text = true_text
	else:
		richTextLabel.text = false_text


func set_label_text(label_text: String) -> void:
	richTextLabel.text = label_text
