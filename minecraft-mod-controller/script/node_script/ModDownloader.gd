extends Node
class_name ModDownloader

# 信号回调
signal progress_changed(downloaded_count: int, total_count: int, current_file: String)
signal file_completed(file_name: String, success: bool)
signal all_downloads_completed()

@export var max_concurrent_downloads: int = 3 ## 最大并发下载数

var _download_queue: Array[Dictionary] = []
var _total_count: int = 0
var _completed_count: int = 0
var _active_http_requests: Array[HTTPRequest] = []

## 开始下载任务
## items 结构: [{ "url": "...", "save_path": "user://mods/xxx.jar", "name": "xxx.jar" }]
func start_download(items: Array[Dictionary]) -> void:
	_download_queue = items.duplicate()
	_total_count = items.size()
	_completed_count = 0
	
	# 启动并发任务
	_process_queue()

func _process_queue() -> void:
	# 检查是否全部完成
	if _completed_count >= _total_count and _active_http_requests.is_empty():
		all_downloads_completed.emit()
		return

	# 保持达到最大并发数
	while _active_http_requests.size() < max_concurrent_downloads and not _download_queue.is_empty():
		var task: Dictionary = _download_queue.pop_front()
		_download_file(task)

func _download_file(task: Dictionary) -> void:
	var url: String = task.get("url", "")
	var save_path: String = task.get("save_path", "")
	var file_name: String = task.get("name", "file.jar")

	if url.is_empty():
		push_warning("跳过空下载 URL: " + file_name)
		_on_task_finished(file_name, false, null)
		return

	# 确保目标文件夹路径存在
	var dir_path := save_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_path))

	# 创建 HTTPRequest 节点
	var http := HTTPRequest.new()
	add_child(http)
	_active_http_requests.append(http)

	# 直接下载并写入到本地文件，节省 RAM
	http.download_file = save_path
	
	http.request_completed.connect(
		func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
			var is_success := (result == HTTPRequest.RESULT_SUCCESS and response_code == 200)
			_on_task_finished(file_name, is_success, http)
	)

	var err := http.request(url)
	if err != OK:
		push_error("HTTP 请求启动失败: " + url)
		_on_task_finished(file_name, false, http)
	else:
		progress_changed.emit(_completed_count, _total_count, file_name)

func _on_task_finished(file_name: String, success: bool, http_node: HTTPRequest) -> void:
	if http_node and is_instance_valid(http_node):
		_active_http_requests.erase(http_node)
		http_node.queue_free()

	_completed_count += 1
	file_completed.emit(file_name, success)
	progress_changed.emit(_completed_count, _total_count, file_name)

	# 推进下一个下载队列
	_process_queue()
