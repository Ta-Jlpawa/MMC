extends BasePopupUI
## 警告弹窗
class_name WarningPopup

@export var title_label: Label
@export var content_label: Label

var warning_type: GameConfig.WarningType = GameConfig.WarningType.INFO ## 警告类型
var content: String = "" ## 警告内容


func set_popup_data(warn_type: GameConfig.WarningType, content_data: String) -> void:
	self.warning_type = warn_type
	self.content = content_data
	update_ui()


func update_ui():
	title_label.text = GameConfig.WarningType.find_key(warning_type)
	content_label.text = content
