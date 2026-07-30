extends Node

var base_dir: String = "" ## 外部文件全局路径
var modcfg_data: Array[ModConfigData] = [] ## 所有模组配置信息
var mod_data: Array[ModData] = [] ## 所有模组信息


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
	modcfg_data = ModConfigData.load_json_to_res(base_dir.path_join("data/has_modcfg_data.json"))
	mod_data = ModData.load_json_to_res(base_dir.path_join("data/has_mod_data.json"))
	print("INFO: 读取modcfg_data: %s" % [modcfg_data])
	print("INFO: 读取mod_data: %s" % [mod_data])
