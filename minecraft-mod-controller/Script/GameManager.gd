extends Node

var base_dir: String = "" ## 外部文件全局路径

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_get_outside_file_path()
	print("INFO: GameManager Ready")


## 加载时获取外部文件夹全局路径
func _get_outside_file_path() -> void:
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://..")
	else:
		OS.get_data_dir()
		base_dir = OS.get_executable_path().get_base_dir()
	print(base_dir)
