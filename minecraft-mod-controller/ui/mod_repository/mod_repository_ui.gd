extends Control


@export var fileCopyProgressPopup: PackedScene
@export var hasModList: HasModList


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hasModList.generate_modcfg_object(GameManager.mod_data)


func _on_add_mod():
	print("添加模组文件接口")
	add_mod()


func _on_remove_mod():
	print("移除模组文件接口")
	remove_mod()


## 添加模组配置
func add_mod() -> void:
	# 选择文件
	var file_dialog: CustomFileDialog = CustomFileDialog.new()
	self.add_child(file_dialog)
	file_dialog.open_file_dialog("选择将要添加的模组文件", ["*.jar;模组文件 (*.jar)"], ["jar"], DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILES)
	var select_file: PackedStringArray = await file_dialog.file_selected
	file_dialog.queue_free()
	if select_file.is_empty(): return
	
	# 文件复制
	var file_copier: FileCopyProgressPopup = fileCopyProgressPopup.instantiate()
	self.add_child(file_copier)
	file_copier.start_copy(select_file, GameManager.get_execpath("modrepo"))
	var copy_state: FileCopyProgressPopup.COPY_STATE = await file_copier.copy_finish
	file_copier.queue_free()
	match copy_state:
		FileCopyProgressPopup.COPY_STATE.NOCHANGE:
			printerr("INFO: 文件没有发生改变")
			return
		FileCopyProgressPopup.COPY_STATE.ERROR:
			printerr("ERROR: 异常:文件复制失败!")
			return
		_:
			pass
			
	# 获取并更新模组信息
	var mod_data: Dictionary[String, ModData] = {}
	var file_name: PackedStringArray = FileOperator.get_file_name(select_file)
	for i in file_name:
		mod_data[i] = ModReader.read_mod_information(GameManager.get_execpath("modrepo/".path_join(i)))
		
	GameManager.append_mod_data(mod_data)
	
	# 写入模组信息到 data/has_mod_data.json
	GameManager.save_mod_data()
	
	# 刷新界面
	hasModList.reload_modcfg_object(GameManager.mod_data)
	print("INFO: 界面刷新")
	

## 移除模组配置
func remove_mod() -> void:
	# 选择文件
	var file_dialog: CustomFileDialog = CustomFileDialog.new()
	self.add_child(file_dialog)
	file_dialog.open_file_dialog("选择将要删除的模组文件", ["*.jar;模组文件 (*.jar)"], ["jar"], DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILES)
	var select_file: PackedStringArray = await file_dialog.file_selected
	file_dialog.queue_free()
	if select_file.is_empty(): return
	# TODO: 此处应当使用更好的文件选择模式，防止用户选择意料之外的文件
	
	# 移除文件
	FileOperator.remove_files(select_file)
	
	# 获取并移除模组信息
	var file_name: PackedStringArray = FileOperator.get_file_name(select_file)
	for i in file_name:
		if GameManager.mod_data.has(i):
			GameManager.mod_data.erase(i)
		else:
			printerr("ERROR: 移除模组 %s 信息失败，模组不存在" % [i])
	
	# 写入模组信息到 data/has_mod_data.json
	GameManager.save_mod_data()
	
	# 刷新界面
	hasModList.reload_modcfg_object(GameManager.mod_data)
	print("INFO: 界面刷新")
