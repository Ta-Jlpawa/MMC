extends Control

@export var createNewConfigPopupUI: CreateNewConfigPopup = null
@export var hasModConfigList: HasModConfigList = null


func _ready() -> void:
	createNewConfigPopupUI.hide()


func _on_add_mod_config():
	print("添加模组配置接口")
	add_mod_config()


func _on_remove_mod_config():
	print("移除模组配置接口")
	remove_mod_config()


## 添加模组配置
func add_mod_config() -> void:
	createNewConfigPopupUI.show()
	var state: String = await createNewConfigPopupUI.close_popup
	match state:
		"Return": # 如果直接返回则无需刷新列表
			pass
		_:
			hasModConfigList.reload_modcfg_object(GameManager.modcfg_data)
	createNewConfigPopupUI.hide()
	print("INFO: 添加配置操作完成")
	

## 移除模组配置
func remove_mod_config() -> void:
	pass
