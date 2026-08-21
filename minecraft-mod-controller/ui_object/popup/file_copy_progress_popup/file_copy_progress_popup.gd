extends Control
## 一个专用于文件复制弹窗组件，会自动创建一个FileCopier子节点，可以显示进度，不支持手动关闭
class_name FileCopyProgressPopup

signal copy_finish(state: COPY_STATE) ## 复制完成时发出，传递一个状态表示是否成功复制

enum COPY_STATE{
	FINISH, ERROR, NOCHANGE
}

@export var page_copy: MarginContainer
@export var page_has_repetitive: RepetitiveFileOperation
@export var title_label: Label
@export var progress_bar: ProgressBar
@export var status_label: RichTextLabel

var copier: FileCopier = null


func _ready() -> void:
	self.hide()
	copier = FileCopier.new()
	self.add_child(copier)
	# 绑定信号
	copier.progress_updated.connect(_on_copy_progress)
	copier.batch_completed.connect(_on_copy_completed)
	copier.copy_error.connect(_on_copy_error)
	
	title_label.text = "准备复制..."
	status_label.text = ""


## 开始复制文件
## 需要传入 文件路径列表 与 目标文件夹
func start_copy(files_to_copy: Array[String], target_folder: String) -> void:
	# 检查是否存在文件重复
	var has_repetitive: Array[String] = []
	for file in files_to_copy:
		if FileAccess.file_exists(target_folder.path_join(file.get_file())):
			has_repetitive.append(file)
	self.show()
	if !has_repetitive.is_empty():
		page_has_repetitive.generate_file_obj(has_repetitive)
		_set_page(page_has_repetitive)
		has_repetitive = await page_has_repetitive.file_chioce_finish # 返回需要跳过的文件路径
		for i in has_repetitive:
			files_to_copy.erase(i)
		print("INFO: [FileCopyProgressPopup] 忽略选择的文件: %s" % [has_repetitive])
		
	if files_to_copy.is_empty():# 没有需要复制的文件时，视为直接完成复制
		_on_copy_stop()
		return
		
	_set_page(page_copy)
	progress_bar.value = 0
	title_label.text = "正在复制文件"
	copier.start_copy(files_to_copy, target_folder) # 启动后台复制


## 实时刷新进度 UI
func _on_copy_progress(copied_bytes: int, total_bytes: int, percent: float, current_file: String) -> void:
	progress_bar.value = percent
	# 将字节转为 MB 显示
	var copied_mb := copied_bytes / 1024.0 / 1024.0
	var total_mb := total_bytes / 1024.0 / 1024.0
	status_label.text = "正在复制: %s (%.1f MB / %.1f MB)" % [current_file, copied_mb, total_mb]


## 文件复制完成时触发
func _on_copy_completed() -> void:
	title_label.text = "所有文件复制完成！"
	print("INFO: 复制操作结束")
	self.hide()
	self.copy_finish.emit(COPY_STATE.FINISH)


func _on_copy_error(path: String, reason: String) -> void:
	printerr("ERROR: 复制失败 [%s]: %s" % [path, reason])
	self.hide()
	self.copy_finish.emit(COPY_STATE.ERROR)
	
	
## 文件复制被撤销时触发
func _on_copy_stop() -> void:
	title_label.text = "文件复制被撤销！"
	print("INFO: 文件复制被撤销")
	self.hide()
	self.copy_finish.emit(COPY_STATE.NOCHANGE)


func _set_page(page: Control):
	page_copy.hide()
	page_has_repetitive.hide()
	page.show()
