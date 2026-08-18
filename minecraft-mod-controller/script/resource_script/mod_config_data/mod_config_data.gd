extends Resource
## 模组配置信息，包含构建与转换相关方法
class_name ModConfigData

## 配置信息
var infomation: ModConfigInformation = ModConfigInformation.new()
## 模组列表，格式为 <模组文件名> : <模组文件路径>
var has_mod_list: Dictionary = {}


### 读取一个json文件并转换为指定类型资源
static func load_json_to_globalres(path: String) -> Dictionary[String, ModConfigData]:
	# 获取存储数据的json路径
	var filename_dict: Dictionary = JsonLoader.load_json_to_data(path)
	for i in filename_dict:
		filename_dict[i] = GameManager.get_execpath("modcfg/".path_join(filename_dict[i]))
	# 将json数据批量转换为资源
	var mod_config_data_dict: Dictionary[String, ModConfigData] = {}
	for i in filename_dict:
		var modcfg_data: ModConfigData = ModConfigData.new()
		var data_dict: Dictionary = JsonLoader.load_json_to_data(filename_dict[i])
		modcfg_data = JsonLoader.dict_to_resource(data_dict, modcfg_data)
		mod_config_data_dict[i] = modcfg_data
	return mod_config_data_dict


## 构建模组配置信息
static func build_modcfg_information(display_name: String, description: String, mc_version: String, modloader_version: String, icon_path: String) -> ModConfigInformation:
	var info: ModConfigInformation = ModConfigInformation.new()
	info.display_name = display_name
	info.description = description
	info.mc_version = mc_version
	info.modloader_version = modloader_version
	info.icon_path = icon_path
	return info


## 构建模组配置数据
static func bulid_modcfg_data(information: ModConfigInformation, has_mod_path: Dictionary[String, String]) -> ModConfigData:
	var modcfg_data: ModConfigData = ModConfigData.new()
	modcfg_data.infomation = information
	modcfg_data.has_mod_list = has_mod_path
	return modcfg_data


## 依照数据，得到约定的配置文件名称，名称带后缀
static func get_filename(data: ModConfigData, id: String) -> String:
	return "%s_%s.json" % [data.infomation.display_name, id]
