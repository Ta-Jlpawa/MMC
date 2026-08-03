extends BasePopupUI
## 创建新模组配置的弹窗
class_name CreateNewConfigPopup

## 关闭弹窗，传递一个状态
signal close_popup(state: String)


func _ready() -> void:
	pass


func _on_create_new_config() -> void:
	print("创建新配置接口")
	

func _on_import_folder() -> void:
	print("导入文件夹接口")


func _on_return() -> void:
	self.close_popup.emit("Return")
