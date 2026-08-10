extends Button
## 使用富文本显示文本的按钮，代价是没有引擎自带的依据按钮状态来使文本变色,但可以额外实现
class_name RichTextButton


@export_multiline() var label_text: String = "按钮文本"

@onready var richTextLabel: RichTextLabel = $RichTextLabel


func _ready() -> void:
	richTextLabel.text = label_text

func set_label_text(label_text: String) -> void:
	richTextLabel.text = label_text
