extends Control

@export var hasModConfigList: HasModConfigList = null
@export var minecraftFolderLineEdit: LineEdit = null
@export var choiceMcFolderRect: TextureRect = null

var object_list: Array[Node] = []
var object_select_id: Array[String] = []
var old_minecraft_folder: String = "" ## 缓存旧的mc文件夹位置文本


func _ready() -> void:
	choiceMcFolderRect.choice_mc_folder_pressed.connect(_on_set_minecraft_folder_with_file_dialog)
	minecraftFolderLineEdit.text = GameManager.minecraft_path
				

func generate_mod_object() -> void:
	for old_node in object_list:
		if is_instance_valid(old_node):
			old_node.disconnect("object_selected", _object_selected)
			old_node.disconnect("object_unselected", _object_unselected)
	object_list.clear()
	object_select_id.clear()
	hasModConfigList.reload_modcfg_object(GameManager.modcfg_data)
	object_list = hasModConfigList.get_nodes()
	for node in object_list:
		node.object_selected.connect(_object_selected)
		node.object_unselected.connect(_object_unselected)


func get_selected_node() -> Array[String]:
	print("INFO: [ModConfigUI.main_ui] 获取选中的配置 %s" % [object_select_id])
	return object_select_id
	

func _on_set_minecraft_folder(toggled: bool):
	if !toggled:
		var text = minecraftFolderLineEdit.text
		if old_minecraft_folder == text: return # 不变则不修改
		if text.is_empty() or !DirAccess.dir_exists_absolute(text): # 不存在则不修改
			minecraftFolderLineEdit.text = old_minecraft_folder
			print("INFO: [ModConfigUI] 输入的.minecraft文件夹: %s 不存在!" % [text])
			return
		GameManager.minecraft_path = text
		print("INFO: [ModConfigUI] 成功选择 %s 作为.minecraft文件夹" % [text])
	else:
		old_minecraft_folder = minecraftFolderLineEdit.text


func _on_set_minecraft_folder_with_file_dialog():
	var file_dialog: CustomFileDialog = CustomFileDialog.new()
	self.add_child(file_dialog)
	file_dialog.open_file_dialog("选择MC根目录(.minecraft文件夹)的位置", [], [], DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_DIR)
	var select_file: PackedStringArray = await file_dialog.file_selected
	file_dialog.queue_free()
	if select_file.is_empty(): return
	GameManager.minecraft_path = select_file[0]
	minecraftFolderLineEdit.text = select_file[0]
	print("INFO: [ModConfigUI] 成功选择 %s 作为.minecraft文件夹" % [select_file[0]])


func unselected_all():
	object_select_id.clear()
	for node in object_list:
		node.unselected()


func _object_selected(node: Node) -> void:
	object_select_id.append(node.id)
	

func _object_unselected(node: Node) -> void:
	if object_list.is_empty(): return
	object_select_id.erase(node.id)
