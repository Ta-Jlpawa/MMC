extends Control

@export var hasModConfigList: HasModConfigList = null


func _ready() -> void:
	pass


func _on_create_mod_config():
	create_mod_config()


func _on_import_dir_config():
	import_dir_config()


func _on_import_zip_config():
	import_zip_config()
	

func _on_remove_mod_config():
	remove_mod_config()


## 创建新模组配置
func create_mod_config() -> void:
	hasModConfigList.reload_modcfg_object(GameManager.modcfg_data)
	print("INFO: 添加配置操作完成")


func import_dir_config() -> void:
	# 选择文件
	var file_dialog: CustomFileDialog = CustomFileDialog.new()
	self.add_child(file_dialog)
	file_dialog.open_file_dialog("选择将要添加的模组文件夹", [], [], DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_DIR)
	var select_file: PackedStringArray = await file_dialog.file_selected
	file_dialog.queue_free()
	if select_file.is_empty(): return
	
	# 读取模组
	
	
	print("INFO: 导入配置操作完成")


func import_zip_config() -> void:
	# 选择文件
	var file_dialog: CustomFileDialog = CustomFileDialog.new()
	self.add_child(file_dialog)
	file_dialog.open_file_dialog("选择将要添加的模组包ZIP压缩文件", ["*.zip;模组压缩包 (*.zip);application/zip"], ["zip"], DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILE)
	var select_file: PackedStringArray = await file_dialog.file_selected
	file_dialog.queue_free()
	if select_file.is_empty(): return
	## TODO: 该方法未完成
	
	print("INFO: 导入配置操作完成")
	

## 移除模组配置
func remove_mod_config() -> void:
	print("INFO: 移除配置操作完成")
