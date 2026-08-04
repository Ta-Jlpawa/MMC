extends Resource
## 模组信息
class_name ModData


var name: String
var author: String
var description: String
var mc_version: String
var mod_version: String
var modloader: String
var icon_path: String


## 读取一个json文件并转换为指定类型资源
static func load_json_to_res(path: String) -> Array[ModData]:
	var data: Array = JsonLoader.load_json_to_data(path)
	var resource_array: Array[ModData] = []
	for i in data:
		var resource = ModData.new()
		for key in i:
			if resource.get(key) != null:
				resource.set(key, i[key])
		resource_array.append(resource)
	return resource_array
