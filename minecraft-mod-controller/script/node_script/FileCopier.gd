extends Node
## 负责文件复制
class_name FileCopier

# 定义信号供 UI 主线程监听
signal progress_updated(copied_bytes: int, total_bytes: int, percent: float, current_file: String)
signal batch_completed()
signal copy_error(file_path: String, reason: String)

var _copy_thread: Thread
# 每次读取的缓冲区大小（64 KB）
const CHUNK_SIZE := 65536 

## 开始批量复制
func start_copy(source_paths: Array[String], target_dir: String) -> void:
	if source_paths.is_empty(): 
		batch_completed.emit.call_deferred()
		_finish_thread.call_deferred()
		return
	if _copy_thread and _copy_thread.is_started():
		printerr("已有复制任务正在进行中！")
		return
	
	_copy_thread = Thread.new()
	_copy_thread.start(_thread_copy_process.bind(source_paths, target_dir))

## 后台线程执行函数
func _thread_copy_process(source_paths: Array[String], target_dir: String) -> void:
	# 1. 确保目标文件夹存在
	if not DirAccess.dir_exists_absolute(target_dir):
		var err := DirAccess.make_dir_recursive_absolute(target_dir)
		if err != OK:
			copy_error.emit.call_deferred(target_dir, "无法创建目标文件夹")
			_finish_thread.call_deferred()
			return

	# 2. 计算所有文件的总字节数（用于精准的百分比进度）
	var total_bytes: int = 0
	var valid_paths: Array[String] = []
	for path in source_paths:
		if FileAccess.file_exists(path):
			var file := FileAccess.open(path, FileAccess.READ)
			if file:
				total_bytes += file.get_length()
				valid_paths.append(path)

	if valid_paths.is_empty():
		_finish_thread.call_deferred()
		return

	# 3. 按块循环复制
	var total_copied_bytes: int = 0
	var last_update_time := Time.get_ticks_msec()

	for path in valid_paths:
		var src_file := FileAccess.open(path, FileAccess.READ)
		if not src_file:
			copy_error.emit.call_deferred(path, "无法打开源文件")
			continue

		var file_name := path.get_file()
		var dst_path := target_dir.path_join(file_name)
		var dst_file := FileAccess.open(dst_path, FileAccess.WRITE)
		if not dst_file:
			copy_error.emit.call_deferred(dst_path, "无法创建目标文件")
			continue

		# 单个文件分块读取并写入
		var file_length := src_file.get_length()
		while src_file.get_position() < file_length:
			var buffer := src_file.get_buffer(CHUNK_SIZE)
			dst_file.store_buffer(buffer)
			total_copied_bytes += buffer.size()

			# 节流控制：每 16ms (约60帧) 最多更新一次 UI 信号，避免高频跨线程调用拖慢性能
			var current_time := Time.get_ticks_msec()
			if current_time - last_update_time > 16:
				last_update_time = current_time
				var percent := (float(total_copied_bytes) / float(total_bytes)) * 100.0 if total_bytes > 0 else 100.0
				progress_updated.emit.call_deferred(total_copied_bytes, total_bytes, percent, file_name)

		src_file.close()
		dst_file.close()

	# 发送最后 100% 进度与完成信号
	progress_updated.emit.call_deferred(total_bytes, total_bytes, 100.0, "全部完成")
	batch_completed.emit.call_deferred()
	_finish_thread.call_deferred()

## 清理线程
func _finish_thread() -> void:
	if _copy_thread and _copy_thread.is_started():
		_copy_thread.wait_to_finish()
