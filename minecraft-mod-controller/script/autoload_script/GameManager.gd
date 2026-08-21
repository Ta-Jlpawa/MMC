extends Node

## 外部文件全局路径，启动时计算
var base_dir: String = ""
## 所有模组配置信息，可有同名配置，同ID配置最多仅可有一个，格式为 <配置文件ID>:<配置信息>
var modcfg_data: Dictionary[String, ModConfigData] = {}
## 所有模组信息，同名模组最多仅可有一个，格式为 <模组文件名>:<模组信息>
var mod_data: Dictionary[String, ModData] = {}
## 设置类信息
var settings: SettingsData = null
## 正在控制的.minecraft文件夹路径
var minecraft_path = ""


func _ready() -> void:
	_get_outside_file_path()
	_get_data()
	_get_minecraft_folder_path()
	_check_setting()
	#print(ModpackReader.parse_zip(get_execpath("test/SFSR_neoforge_modpack 0.0.1.zip")))
	print("INFO: [GameManager] Ready")


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
		printerr("ERROR: [GameManager] 修改程序设置失败,不存在的设置 %s 或值 %s" % [key, value])


## 保存程序设置
func save_setting() -> void:
	JsonWriter.write_json(get_execpath("data/settings.json"), settings)
	pass


## 重置程序设置并保存
func reset_setting() -> void:
	settings = SettingsData.new()
	save_setting()
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
	JsonWriter.write_json(get_execpath("data/has_mod_data.json"), mod_data_json)
	print("INFO: [GameManager] 模组数据保存")
	
	
func append_modcfg_data(data: Dictionary) -> void:
	modcfg_data.merge(data, true)


func save_modcfg_data():
	var modcfg_data_json: Dictionary[String, String] = {}
	for id in modcfg_data:
		var data = modcfg_data[id]
		modcfg_data_json[id] = ModConfigData.get_filename(data, id)
	JsonWriter.write_json(get_execpath("data/has_modcfg_data.json"), modcfg_data_json)
	print("INFO: [GameManager] 模组配置保存")
	
	
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
	settings = JsonLoader.dict_to_resource(JsonLoader.load_json_to_data(get_execpath("data/settings.json")), SettingsData.new())
	print("INFO: [GameManager] 读取settings: %s" % [settings])
	modcfg_data = ModConfigData.load_json_to_globalres(get_execpath("data/has_modcfg_data.json"))
	print("INFO: [GameManager] 读取modcfg_data: %s" % [modcfg_data])
	mod_data = ModData.load_json_to_globalres(get_execpath("data/has_mod_data.json"))
	print("INFO: [GameManager] 读取mod_data: %s" % [mod_data])


## 获取 minecraft_folder 位置
func _get_minecraft_folder_path() -> void:
	if settings.minecraft_folder == "":
		var appdata_path := OS.get_environment("APPDATA")
		appdata_path = appdata_path.replace("\\", "/") # 踩坑: 统一格式
		var path = appdata_path.path_join(".minecraft")
		if DirAccess.dir_exists_absolute(path):
			minecraft_path = path
			settings.minecraft_folder = minecraft_path
			save_setting()
		else:
			print("INFO: [GameManager] 未检测到mc文件夹,需要用户手动设置")
			# TODO: 此处可以添加弹窗让用户设置
	else:
		minecraft_path = settings.minecraft_folder
	
	print("INFO: [GameManager] 读取minecraft_folder_path: %s" % [minecraft_path])
	

## 检查设置
func _check_setting() -> void:
	print("INFO: [GameManager] 检查设置完毕")
	
	
	
