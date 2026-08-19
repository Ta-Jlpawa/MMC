extends Control


@export var fileCopyProgressPopup: PackedScene
@export var hasModListNode: HasModList

var object_list: Array[Node] = []
var selected_object: Array[String] = [] ## 将要移除的模组名


func _ready() -> void:
	generate_mod_object(GameManager.mod_data)


func _on_add_mod():
	print("添加模组文件接口")
	add_mod()


func _on_remove_mod():
	print("移除模组文件接口")
	remove_mod()


## 添加模组
func add_mod() -> void:
	# 选择文件
	var file_dialog: CustomFileDialog = CustomFileDialog.new()
	self.add_child(file_dialog)
	file_dialog.open_file_dialog("选择将要添加的模组文件", ["*.jar;模组文件 (*.jar);application/java-archive"], ["jar"], DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILES)
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
			print("INFO: 文件没有发生改变")
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
	generate_mod_object(GameManager.mod_data)
	print("INFO: 界面刷新")
	

## 移除模组
func remove_mod() -> void:
	if selected_object.is_empty():
		print("INFO: 移除模组操作失败: 未选择配置")
		return
	
	# 移除文件, 获取并移除模组信息
	for i in selected_object:
		var file_path: String = GameManager.get_execpath("modrepo/".path_join(i))
		FileOperator.remove_file(file_path)
		if GameManager.mod_data.has(i):
			GameManager.mod_data.erase(i)
		else:
			printerr("ERROR: 移除模组 %s 信息失败，模组不存在" % [i])
	
	# 写入模组信息到 data/has_mod_data.json
	GameManager.save_mod_data()
	
	# 刷新界面
	generate_mod_object(GameManager.mod_data)
	print("INFO: 界面刷新")


func generate_mod_object(data: Dictionary[String, ModData]) -> void:
	for old_node in object_list:
		if is_instance_valid(old_node):
			old_node.disconnect("object_selected", _object_selected)
			old_node.disconnect("object_unselected", _object_unselected)
	object_list.clear()
	selected_object.clear()
	hasModListNode.reload_mod_object(data)
	object_list = hasModListNode.get_nodes()
	for node in object_list:
		node.object_selected.connect(_object_selected)
		node.object_unselected.connect(_object_unselected)
		

func _object_selected(node: Node) -> void:
	selected_object.append(node.id)
	

func _object_unselected(node: Node) -> void:
	if object_list.is_empty(): return
	selected_object.erase(node.id)
