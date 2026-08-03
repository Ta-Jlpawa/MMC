extends Control
## 一个专用于文件复制弹窗组件，会自动创建一个FileCopier子节点，可以显示进度，不支持手动关闭
class_name FileCopyProgressPopup

signal copy_finish(state: bool) ## 复制完成时发出，传递一个状态表示是否成功复制

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
	self.show()
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
	print("INFO: 复制成功")
	self.hide()
	self.copy_finish.emit(true)


func _on_copy_error(path: String, reason: String) -> void:
	printerr("ERROR: 复制失败 [%s]: %s" % [path, reason])
	self.hide()
	self.copy_finish.emit(false)
