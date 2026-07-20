extends Node

var base_dir: String = "" ## 外部文件全局路径
var json_loader: LoadJson = LoadJson.new() ## JSON读取器
var modcfg_data: Array[Variant] = []


func _ready() -> void:
	_get_outside_file_path()
	_get_modcfg_data()
	print("INFO: GameManager Ready")


## 加载时获取外部文件夹全局路径(仅执行一次)
func _get_outside_file_path() -> void:
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://..")
	else:
		OS.get_data_dir()
		base_dir = OS.get_executable_path().get_base_dir()
	print(base_dir)


func _get_modcfg_data() -> void:
	modcfg_data = json_loader.load_json_to_dict(GameManager.base_dir.path_join("data/has_modcfg_data.json"))
	print("INFO: 读取modcfg_data: %s", modcfg_data)
