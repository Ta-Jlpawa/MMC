extends Control


signal is_continue(action: bool)

# 模组列表
@export var hasModListNode: HasModList = null
# 配置信息设置
@export var iDNode: Label
@export var setDisplayNameNode: LineEdit
@export var setDescriptionNode: TextEdit
@export var setMCVersionNode: Label
@export var setModLoaderVersionNode: Label
# 操作选项
@export var richCheckButton: RichCheckButton = null



func generate_mod_object(data: Dictionary[String, ModData]) -> void:
	richCheckButton.reset()
	hasModListNode.reload_mod_object(data)
	
	var id: String = IDGenerator.generate_modcfg_id()
	iDNode.text = id # ID
	var cfg_nums: int = GameManager.modcfg_data.size()
	setDisplayNameNode.text = "模组配置 " + str(cfg_nums + 1) # 默认名称
	setDescriptionNode.text = "" # 默认为空
	setMCVersionNode.text = "未知" # TODO: 需要实现
	setModLoaderVersionNode.text = "未知" # TODO: 需要实现
	


## 获取可选项的状态
func get_option_state() -> bool:
	return richCheckButton.get_state()


## 获取配置信息
func get_modcfg_infomation() -> ModConfigInformation:
	var data: ModConfigInformation = ModConfigInformation.new()
	data.display_name = setDisplayNameNode.text
	data.description = setDescriptionNode.text
	data.mc_version = setMCVersionNode.text
	data.modloader_version = setModLoaderVersionNode.text
	return data


func get_modcfg_id() -> String:
	return iDNode.text


func _on_continue_pressed():
	self.is_continue.emit(true)
	

func _on_back_to_mainui_pressed():
	self.is_continue.emit(false)
