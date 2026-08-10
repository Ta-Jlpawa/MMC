extends Node

## 外部文件全局路径，启动时计算
var base_dir: String = ""
## 所有模组配置信息，可有同名配置，同ID配置最多仅可有一个，格式为 <配置文件ID>:<配置信息>
var modcfg_data: Dictionary[String, ModConfigData] = {}
## 所有模组信息，同名模组最多仅可有一个，格式为 <模组文件名>:<模组信息>
var mod_data: Dictionary[String, ModData] = {}
## 设置类信息
var settings: Dictionary = {}


func _ready() -> void:
	_get_outside_file_path()
	_get_data()
	print("INFO: GameManager Ready")
	#JsonWriter.save_res_to_json(get_execpath("data/has_modcfg_data.json"), modcfg_data)


## 通过相对路径，获取要操作的文件的完整路径
func get_execpath(path: String) -> String:
	return base_dir.path_join(path)


## 获取指定程序设置
func get_setting(key: String) -> Variant:
	return settings.get(key)
	

## 修改程序设置
func set_setting(key: String, value: Variant) -> void:
	if key in settings:
		settings[key] = value
	else:
		printerr("ERROR: 修改程序设置失败,不存在的设置 %s 或值 %s" % [key, value])


## 保存程序设置
func save_setting() -> void:
	#JsonWriter.save_res_to_json(get_execpath("data/settings.json"), settings)
	pass


func reset_setting() -> void:
	settings = GameConfig.setting_copy
	#JsonWriter.save_res_to_json(get_execpath("data/settings.json"), settings)
	pass


func add_mod_data(key: String, value: ModData) -> void:
	mod_data[key] = value


func append_mod_data(data: Dictionary) -> void:
	mod_data.merge(data, true)


func save_mod_data():
	var mod_data_json: Dictionary[String, Dictionary] = {}
	for i in mod_data:
		var value = mod_data[i]
		mod_data_json[i] = JsonWriter.resource_to_dict(value)
	JsonWriter.append_json(get_execpath("data/has_mod_data.json"), mod_data_json)
	print("INFO: 模组数据保存")

## 加载时获取外部文件夹全局路径(仅执行一次)
func _get_outside_file_path() -> void:
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://..")
	else:
		OS.get_data_dir()
		base_dir = OS.get_executable_path().get_base_dir()
	print(base_dir)
	
	
## 初始加载数据
func _get_data() -> void:
	settings = JsonLoader.load_json_to_data(get_execpath("data/settings.json"))
	print("INFO: 读取settings: %s" % [settings])
	modcfg_data = ModConfigData.load_json_to_globalres(get_execpath("data/has_modcfg_data.json"))
	print("INFO: 读取modcfg_data: %s" % [modcfg_data])
	mod_data = ModData.load_json_to_globalres(get_execpath("data/has_mod_data.json"))
	print("INFO: 读取mod_data: %s" % [mod_data])
	
	
