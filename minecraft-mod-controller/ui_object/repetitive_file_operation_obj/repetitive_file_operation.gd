extends MarginContainer
class_name RepetitiveFileOperation


signal file_chioce_finish(file_path: Array[String])


@export var overwrite_button: Button
@export var skip_button: Button
@export var overwrite_all_button: Button
@export var skip_all_button: Button
@export var generate_root: Node
@export var fileObjStyle: PackedScene

var current_file: Array[String] = [] ## 当前所有需要处理的文件
var skip_file: Array[String] = [] ## 选择忽略的文件
var button_list: Array[FileObj] = [] ## 生成的按钮列表


func generate_file_obj(file_path: Array[String]) -> void:
	var id: int = 0
	for i in file_path:
		current_file.append(i)
		var file_name = i.get_file()
		var file_obj: FileObj = fileObjStyle.instantiate()
		file_obj.set_data(file_name, i, id)
		button_list.append(file_obj)
		generate_root.add_child(file_obj)
		id += 1


func clear_file_obj():
	var obj: Array[Node] = self.get_children()
	for i in obj:
		i.queue_free()
	current_file.clear()


## 选择完成后执行
func _choice_finish():
	file_chioce_finish.emit(skip_file.duplicate())
	clear_file_obj()
	skip_file.clear()


func _on_overwrite_button_pressed():
	var choice_button: Array[FileObj] = []
	for i: FileObj in button_list:
		if i.is_pressed():
			choice_button.append(i)
	for i: FileObj in choice_button: # 移除已选按钮
		button_list.erase(i)
		generate_root.remove_child(i)
		i.queue_free()
	if button_list.is_empty(): _choice_finish()


func _on_skip_button_pressed():
	var choice_button: Array[FileObj] = []
	for i: FileObj in button_list:
		if i.is_pressed():
			skip_file.append(current_file[i.id]) # 标记跳过文件
			choice_button.append(i)
	for i: FileObj in choice_button:
		button_list.erase(i)
		generate_root.remove_child(i)
		i.queue_free()
	if button_list.is_empty(): _choice_finish()
	
	
func _on_overwrite_all_button_pressed():
	_choice_finish()
	
	
func _on_skip_all_button_pressed():
	skip_file.append_array(current_file)
	_choice_finish()
