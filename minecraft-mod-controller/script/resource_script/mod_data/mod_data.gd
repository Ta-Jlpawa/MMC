extends Resource
## 数据类：模组信息类
class_name ModData

var infomation: ModInfomation = ModInfomation.new()


### 读取一个json文件并转换为指定类型资源
static func load_json_to_globalres(path: String) -> Dictionary[String, ModData]:
	var mod_data_dict: Dictionary[String, ModData] = {}
	var dict: Dictionary = JsonLoader.load_json_to_data(path)
	for i in dict:
		var mod_data: ModData = ModData.new()
		mod_data = JsonLoader.dict_to_resource(dict[i], mod_data)
		mod_data_dict[i] = mod_data
	return mod_data_dict
