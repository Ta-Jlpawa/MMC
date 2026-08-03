extends Node
class_name  CustomFileDialog

signal file_dialog_closed() ## 文件选择框完成或被关闭时发出
signal file_selected(selected_paths: PackedStringArray) ## 文件选择完成效验后发出，传递所选择的文件路径

var _file_extensions: PackedStringArray = [] ## 合法的文件后缀，用于文件效验

const CONFIG_KEY := "file_dialog_last_dir_mod"


func _ready() -> void:
	pass


## 调起 OS 原生文件选择框
## 传入 窗口标题, 过滤器数组（格式: "扩展名匹配;描述文本"）, 合法的文件后缀名(不包含"."), 选择模式
## filters 数组中的每个过滤字符串都应该按照这种格式来编写：*.png,*.jpg,*.jpeg;Image Files;image/png,image/jpeg。过滤器的描述文本（比如这里的 Image Files）是可选的，可以省略。不过，建议同时设置文件扩展名和 MIME 类型。也可以参考 FileDialog.filters
# 一个示例如下(示例中未指定MIME类型)
# var filters := PackedStringArray([
#		"*.png, *.jpg;图片文件 (*.png, *.jpg)",
#		"*.json;配置文件 (*.json)"
# 	])
func open_file_dialog(title: String, filters: PackedStringArray, extensions: PackedStringArray, mode: DisplayServer.FileDialogMode) -> void:
	var current_dir: String = _get_last_dir()
	var filename: String= ""
	var show_hidden: bool= false
	var callback := Callable(self, "_on_file_dialog_closed")
	_file_extensions = extensions
	
	DisplayServer.file_dialog_show(
		title, current_dir, filename, show_hidden, mode, filters, callback
	)
	
	get_tree().paused = true


## 原生弹窗关闭后的回调函数
## 回调函数会包含以下参数：status: bool（状态）、selected_paths: PackedStringArray（被选中的路径）、selected_filter_index: int（被选中的过滤器索引）
func _on_file_dialog_closed(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int) -> void:
	get_tree().paused = false
	self.file_dialog_closed.emit()
	
	if not status or selected_paths.is_empty():
		print("INFO: 用户取消了选择")
		self.file_selected.emit([])
		return

	# 后缀校验
	for file_path: String in selected_paths:
		if _is_extension_valid(file_path):
			print("INFO: 成功选择合法文件: %s" % file_path)
		else:
			_show_native_error_alert("选择了非允许类型的文件！") # 可替换
			printerr("ERROR: 文件选择被废弃")
			return
			
	# 从全路径中提取文件夹路径并保存
	var file_path := selected_paths[0]
	var folder_dir := file_path.get_base_dir()
	_save_last_dir(folder_dir)
	
	self.file_selected.emit(selected_paths)


## 验证拓展名是否有效
func _is_extension_valid(path: String) -> bool:
	return path.get_extension().to_lower() in _file_extensions


## 读取最后一次执行选择的目录
func _get_last_dir() -> String:
	var default_dir := OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	var saved_dir: String = GameManager.get_setting(CONFIG_KEY)
	if saved_dir != null and not saved_dir.is_empty():
		if DirAccess.dir_exists_absolute(saved_dir): # 校验保存的路径在硬盘上是否还存在（防止目录被改名或删除）
			return saved_dir
	return default_dir


## 持久化保存目录
func _save_last_dir(dir_path: String) -> void:
	GameManager.set_setting(CONFIG_KEY, dir_path)
	GameManager.save_setting()


## 显示Godot默认样式提示框
func _show_default_error_alert(msg: String) -> void:
	var alert := AcceptDialog.new()
	alert.dialog_text = msg
	alert.title = "错误"
	add_child(alert)
	alert.popup_centered()
	alert.confirmed.connect(alert.queue_free)


## 显示系统原生提示框
func _show_native_error_alert(msg: String) -> void:
	OS.alert(msg, "错误!")
	

## 显示自定义样式提示框
func _show_custom_error_alert(msg: String) -> void:
	printerr("ERROR: 该方法未实现!!!")
	# TODO: 在此处处理文件读取逻辑
