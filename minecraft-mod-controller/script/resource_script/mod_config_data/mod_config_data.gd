extends Resource
## 模组配置信息
class_name ModConfigData

var infomation: ModConfigInformation = null
var has_mod_list: PackedStringArray = []



## 读取一个json文件并转换为指定类型资源
static func load_json_to_res(path: String) -> Array[ModConfigData]:
	var data: Array = JsonLoader.load_json_to_data(path)
	var resource_array: Array[ModConfigData] = []
	for i in data:
		var resource = ModConfigData.new()
		for key in i:
			if resource.get(key) != null:
				resource.set(key, i[key])
		resource_array.append(resource)
	return resource_array
