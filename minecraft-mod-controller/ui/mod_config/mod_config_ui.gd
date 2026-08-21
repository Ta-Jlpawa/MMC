extends Control

@export var fileCopyProgressPopup: PackedScene

@export var mainUI: Control = null
@export var createCfgUI:  Control = null
@export var importDirUI: Control = null


func _ready() -> void:
	mainUI.generate_mod_object()
	_show_target_ui(mainUI)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# 处理LineEdit的聚焦问题
			var focused := get_viewport().gui_get_focus_owner()

			if focused is LineEdit:
				if focused.is_editing(): # 注:此处检测防止在选中LineEdit时按下enter导致编辑模式退出但焦点仍在的问题，防止多余触发
					focused.unedit()
					focused.editing_toggled.emit(false)
				focused.release_focus()


func _on_create_mod_config():
	create_mod_config()


func _on_import_dir_config():
	import_dir_config()


func _on_import_zip_config():
	import_zip_config()
	

func _on_remove_mod_config():
	remove_mod_config()


func _on_use_mod_config():
	use_mod_config()


## 创建新模组配置
func create_mod_config() -> void:
	createCfgUI.init_ui()
	_show_target_ui(createCfgUI)
	
	# 等待继续
	var is_continue: bool = await createCfgUI.is_continue
	if !is_continue:
		_show_target_ui(mainUI)
		print("INFO: 用户选择取消导入")
		return
		
	var jar_path: Dictionary[String, String] = createCfgUI.get_modcfg_has_mods()
	var mod_data: Dictionary[String, ModData] = createCfgUI.get_modcfg_moddata()
	# 按照选择决定是否导入模组仓库
	if createCfgUI.get_option_state():
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
		for i in jar_path: # 导入仓库后，路径应修改为仓库路径
			jar_path[i] = GameManager.get_execpath("modrepo/".path_join(i))
		GameManager.append_mod_data(mod_data)
		GameManager.save_mod_data()
		print("INFO: %s 个模组已导入模组仓库" % [mod_data.size()])
		
	# 构建模组配置信息
	var modcfg_data: ModConfigData = ModConfigData.bulid_modcfg_data(createCfgUI.get_modcfg_infomation(), jar_path)
	var id: String = createCfgUI.get_modcfg_id()
	
	# 创建配置文件到modcfg文件夹
	var file_name: String = ModConfigData.get_filename(modcfg_data, id)
	JsonWriter.write_json(GameManager.get_execpath("modcfg/%s" % [file_name]), modcfg_data)
	
	# 同步保存 GameManager 与 data/has_modcfg_data.json 中数据
	var modcfg_path_with_id: Dictionary[String, ModConfigData] = {}
	modcfg_path_with_id[id] = modcfg_data
	print("INFO: 构建成功，新增信息为 %s" % [modcfg_path_with_id])
	GameManager.append_modcfg_data(modcfg_path_with_id)
	GameManager.save_modcfg_data()
	
	# 刷新界面
	mainUI.generate_mod_object()
	_show_target_ui(mainUI)
	print("INFO: 添加配置操作完成")


## 导入文件夹
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
	if jar_path.is_empty():
		print("INFO: 文件夹不存在模组文件")
		return
	var mod_data: Dictionary[String, ModData] = {}
	for i in jar_path:
		mod_data[i] = ModReader.read_mod_information(jar_path[i])
	_show_target_ui(importDirUI)
	importDirUI.generate_mod_object(mod_data)
	
	# 等待继续或返回
	var is_continue: bool = await importDirUI.is_continue
	if !is_continue:
		_show_target_ui(mainUI)
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
		for i in jar_path: # 导入仓库后，路径应修改为仓库路径
			jar_path[i] = GameManager.get_execpath("modrepo/".path_join(i))
		GameManager.append_mod_data(mod_data)
		GameManager.save_mod_data()
		print("INFO: %s 个模组已导入模组仓库" % [mod_data.size()])
	
	# 构建模组配置信息
	var modcfg_data: ModConfigData = ModConfigData.bulid_modcfg_data(importDirUI.get_modcfg_infomation(), jar_path)
	var id: String = importDirUI.get_modcfg_id()
	
	# 创建配置文件到modcfg文件夹
	var file_name: String = ModConfigData.get_filename(modcfg_data, id)
	JsonWriter.write_json(GameManager.get_execpath("modcfg/%s" % [file_name]), modcfg_data)
	
	# 同步保存 GameManager 与 data/has_modcfg_data.json 中数据
	var modcfg_path_with_id: Dictionary[String, ModConfigData] = {}
	modcfg_path_with_id[id] = modcfg_data
	print("INFO: 构建成功，新增信息为 %s" % [modcfg_path_with_id])
	GameManager.append_modcfg_data(modcfg_path_with_id)
	GameManager.save_modcfg_data()
	
	# 刷新界面
	mainUI.generate_mod_object()
	_show_target_ui(mainUI)
	
	print("INFO: 导入配置操作完成")


## 导入整合包
func import_zip_config() -> void:
	print("INFO: 该方法未完成")
	return
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
	var selected_cfg: Array[String] = mainUI.get_selected_node()
	if selected_cfg.is_empty():
		print("INFO: 移除配置操作失败: 未选择配置")
		return
		
	for id in selected_cfg:
		if !GameManager.modcfg_data.has(id): continue
		# 移除文件
		var file_path = GameManager.get_execpath("modcfg/".path_join(ModConfigData.get_filename(GameManager.modcfg_data.get(id), id)))
		FileOperator.remove_file(file_path)
		# 移除数据
		GameManager.modcfg_data.erase(id)
		GameManager.save_modcfg_data()
	
	print("INFO: 移除配置操作完成")
	mainUI.generate_mod_object()
	mainUI.unselected_all()


## 在模组文件夹中应用配置
func use_mod_config() -> void:
	# 选择检查
	var selected_cfg: Array[String] = mainUI.get_selected_node()
	if selected_cfg.is_empty():
		print("INFO: [ModConfigUI] 应用配置操作失败: 未选择配置")
		return
	if selected_cfg.size() > 1:
		print("INFO: [ModConfigUI] 一次只能应用一个配置!")
		mainUI.unselected_all()
		return
	var mod_list: Dictionary = GameManager.modcfg_data[selected_cfg[0]].has_mod_list # 获得模组列表, 格式为 <模组文件名> : <模组文件路径>
	
	#var access: DirAccess = DirAccess.open(GameManager.minecraft_path)
	#if access == null:
		#printerr("ERROR: [ModConfigUI] 打开文件夹错误: %s" % [DirAccess.get_open_error()])
		#return
	
	var mod_dir_path: String = GameManager.minecraft_path.path_join("mods")
	# 检查文件夹是否存在
	if !DirAccess.dir_exists_absolute(mod_dir_path):
		print("INFO: [ModConfigUI] mod文件夹不存在，尝试创建: %s" % [mod_dir_path])
		DirAccess.make_dir_absolute(mod_dir_path)
		
	var mod_paths: Array[String] = []
	for mod_name in mod_list:
		var mod_path: String = mod_list[mod_name]
		if !FileAccess.file_exists(mod_path): # 检查模组是否存在
			printerr("ERROR: [ModConfigUI] mod文件不存在: %s" % [mod_path])
			return
		mod_paths.append(mod_path)
	# 复制文件
	var file_copier: FileCopyProgressPopup = fileCopyProgressPopup.instantiate()
	self.add_child(file_copier)
	print(mod_dir_path)
	file_copier.start_copy(mod_paths, mod_dir_path)
	var copy_state: FileCopyProgressPopup.COPY_STATE = await file_copier.copy_finish
	file_copier.queue_free()
	match copy_state:
		FileCopyProgressPopup.COPY_STATE.NOCHANGE:
			print("INFO: 文件没有发生改变")
		FileCopyProgressPopup.COPY_STATE.ERROR:
			printerr("ERROR: 异常:文件复制失败!")
		_:
			pass
	
	## 尝试创建符号链接
	## TODO: 需要解决权限问题再启用
	#for mod_name in mod_list:
		#var mod_path: String = mod_list[mod_name]
		#if !FileAccess.file_exists(mod_path): # 检查模组是否存在
			#printerr("ERROR: [ModConfigUI] mod文件不存在: %s" % [mod_path])
			#return
		#var error := access.create_link(mod_path, mod_dir_path)
		#if error == OK:
			#print("INFO: [ModConfigUI] 创建符号链接成功")
		#else:
			#if OS.get_name() == "Windows": # Windows创建失败可能是因为没有权限，尝试调用cmd创建
				#print("INFO: [ModConfigUI] 创建失败, 尝试使用CMD创建符号链接，目标路径: %s ，模组路径: %s" % [mod_dir_path, mod_path])
				##var bat: FileAccess = FileAccess.open(GameManager.get_execpath("tools/create_link_tool.bat"), FileAccess.WRITE)
				##bat.store_string()
				#var output: Array = []
				#var is_success: int = OS.execute("runas", ["cmd.exe", "/C", "mklink", mod_dir_path.replace("/", "\\"), mod_path.replace("/", "\\")], output, true)
				#print("INFO: [ModConfigUI] CMD输出: %s" % [output])
				#if is_success == -1:
					#printerr("ERROR: [ModConfigUI] 尝试使用CMD创建符号链接失败： %s", [output])
				#
			#else:
				#printerr("ERROR: [ModConfigUI] 创建符号链接失败：", error)
			
	mainUI.unselected_all()
	print("INFO: [ModConfigUI] 应用配置操作完成")

func _show_target_ui(node: Node):
	for i in self.get_children():
		i.visible = false
	node.visible = true
