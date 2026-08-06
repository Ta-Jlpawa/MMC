extends Control


@export var fileCopyProgressPopup: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
	print("INFO: 用户选择 %s" % [select_file])
	file_dialog.queue_free()
	if select_file.is_empty(): return
	
	# 文件复制
	var file_copier: FileCopyProgressPopup = fileCopyProgressPopup.instantiate()
	self.add_child(file_copier)
	file_copier.start_copy(select_file, GameManager.get_execpath("modrepo"))
	var copy_state: bool = await file_copier.copy_finish
	file_copier.queue_free()
	if not copy_state:
		printerr("ERROR: 异常:文件复制失败!")
		return
	
	# 获取模组信息
	var file_name: Array[String] = []
	var mod_data: Array[ModData] = []
	for i in select_file:
		file_name.append(i.split('/')[-1])
	for i in file_name:
		mod_data.append(ModReader.read_mod_information(GameManager.get_execpath("modrepo/".path_join(i))))
	
	# 写入模组信息到 data/has_mod_data.json
	

## 移除模组配置
func remove_mod() -> void:
	pass
