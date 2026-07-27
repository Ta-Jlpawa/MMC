extends Resource
class_name ModConfigData


var name: String
var description: String
var mc_version: String
var modloader_version: String
var icon_path: String


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
