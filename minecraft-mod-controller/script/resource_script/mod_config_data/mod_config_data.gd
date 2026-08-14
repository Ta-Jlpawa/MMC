extends Resource
## 模组配置信息
class_name ModConfigData

var infomation: ModConfigInformation = ModConfigInformation.new()
var has_mod_list: PackedStringArray = []


### 读取一个json文件并转换为指定类型资源
static func load_json_to_globalres(path: String) -> Dictionary[String, ModConfigData]:
	var mod_config_data_dict: Dictionary[String, ModConfigData] = {}
	var dict: Dictionary = JsonLoader.load_json_to_data(path)
	for i in dict:
		var modcfg_data: ModConfigData = ModConfigData.new()
		modcfg_data = JsonLoader.dict_to_resource(dict[i], modcfg_data)
		mod_config_data_dict[i] = modcfg_data
	return mod_config_data_dict
	
	## TODO： 逻辑应当修改为依据modconfig的路径去寻找data.json文件，随后解析json文件并添加到字典中
