extends Control

@export var fileCopyProgressPopup: PackedScene

@export var mainUI: Control = null
@export var importDirUI: Control = null


func _ready() -> void:
	mainUI.show()
	importDirUI.hide()


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
	mainUI.generate_mod_object()
	print("INFO: 添加配置操作完成")


func import_dir_config() -> void:
	# 选择文件
	var file_dialog: CustomFileDialog = CustomFileDialog.new()
	self.add_child(file_dialog)
	file_dialog.open_file_dialog("选择将要添加的模组文件夹", [], [], DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_DIR)
	var select_file: PackedStringArray = await file_dialog.file_selected
	file_dialog.queue_free()
	if select_file.is_empty(): return
	
	# 查找目录下的模组文件，解析模组信息
	var jar_path: Dictionary[String, String] = ModConfigReader.read_mod_from_dir(select_file[0]) # 形如 <文件名> : <文件全局路径> 的字典
	var mod_data: Dictionary[String, ModData] = {}
	for i in jar_path:
		mod_data[i] = ModReader.read_mod_information(jar_path[i])
	mainUI.hide()
	importDirUI.show()
	importDirUI.generate_mod_object(mod_data)
	
	# 等待继续或返回
	var is_continue: bool = await importDirUI.is_continue
	if !is_continue:
		importDirUI.hide()
		mainUI.show()
		print("INFO: 用户选择取消导入")
		return
	
	# 按照选择决定是否导入模组仓库
	if importDirUI.get_option_state():
		var file_copier: FileCopyProgressPopup = fileCopyProgressPopup.instantiate()
		self.add_child(file_copier)
		file_copier.start_copy(jar_path.values(), GameManager.get_execpath("modrepo"))
		var copy_state: FileCopyProgressPopup.COPY_STATE = await file_copier.copy_finish
		file_copier.queue_free()
		match copy_state:
			FileCopyProgressPopup.COPY_STATE.NOCHANGE:
				print("INFO: 文件没有发生改变")
			FileCopyProgressPopup.COPY_STATE.ERROR:
				printerr("ERROR: 异常:文件复制失败!")
			_:
				pass
		GameManager.append_mod_data(mod_data)
		GameManager.save_mod_data()
		print("INFO: %s 个模组已导入模组仓库" % [mod_data.size()])
	
	# 构建模组配置信息
	var modcfg_data: ModConfigData = ModConfigData.bulid_modcfg_data(importDirUI.get_modcfg_infomation(), jar_path)
	var id: String = importDirUI.get_modcfg_id()
	
	# 创建配置文件到modcfg文件夹
	var file_name: String = ModConfigData.get_filename(modcfg_data, id)
	JsonWriter.write_json(GameManager.get_execpath("modcfg/%s.json" % [file_name]), modcfg_data)
	
	# 同步保存 GameManager 与 data/has_modcfg_data.json 中数据
	var modcfg_path_with_id: Dictionary[String, ModConfigData] = {}
	modcfg_path_with_id[id] = modcfg_data
	print("INFO: 构建成功，新增信息为 %s" % [modcfg_path_with_id])
	GameManager.append_modcfg_data(modcfg_path_with_id)
	GameManager.save_modcfg_data()
	
	# 刷新界面
	mainUI.generate_mod_object()
	importDirUI.hide()
	mainUI.show()
	
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
