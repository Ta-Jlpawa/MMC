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

## 将要导入的模组
var has_mod: Dictionary[String, ModData] = {}
## 选择将要移除的模组名
var selected_object: Array[String] = []


func init_ui() -> void:
	has_mod.clear()
	richCheckButton.reset()
	var id: String = IDGenerator.generate_modcfg_id()
	iDNode.text = id # ID
	var cfg_nums: int = GameManager.modcfg_data.size()
	setDisplayNameNode.text = "模组配置 " + str(cfg_nums + 1) # 默认名称
	setDescriptionNode.text = "" # 默认为空
	setMCVersionNode.text = "未知" # TODO: 需要实现
	setModLoaderVersionNode.text = "未知" # TODO: 需要实现


func generate_mod_object(data: Dictionary[String, ModData]) -> void:
	hasModListNode.reload_mod_object(data)


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


## 向配置中添加模组
func _on_add_mod_pressed():
	# 选择文件
	var file_dialog: CustomFileDialog = CustomFileDialog.new()
	self.add_child(file_dialog)
	file_dialog.open_file_dialog("选择将要添加的模组文件", ["*.jar;模组文件 (*.jar);application/java-archive"], ["jar"], DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILES)
	var select_file: PackedStringArray = await file_dialog.file_selected
	file_dialog.queue_free()
	if select_file.is_empty(): return
	
	# 获取模组信息
	var mod_data: Dictionary[String, ModData] = {}
	for file_path in select_file:
		mod_data[file_path.get_file()] = ModReader.read_mod_information(file_path)
		
	# 刷新列表
	has_mod.merge(mod_data, true)
	generate_mod_object(mod_data)


## 移除配置中的模组
func _on_remove_mod_pressed():
	for mod_name in selected_object:
		has_mod.erase(mod_name)
	selected_object.clear()
	generate_mod_object(has_mod)
	print("INFO: %s 个模组已移除" % [selected_object.size()])
	

func _on_continue_pressed():
	self.is_continue.emit(true)
	

func _on_back_to_mainui_pressed():
	self.is_continue.emit(false)
