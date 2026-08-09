extends Resource
## 模组信息
class_name ModData

var infomation: ModInfomation = ModInfomation.new()


## 读取一个json文件并转换为指定类型资源
static func load_json_to_res(path: String) -> Dictionary[String, ModData]:
	var json: Dictionary = JsonLoader.load_json_to_data(path)
	var resource_data: Dictionary[String, ModData] = {}
	for i in json:
		var resource = ModData.new()
		var data: Dictionary = json[i]
		for key in data:
			if resource.infomation.get(key) != null:
				resource.set(key, mod_data[key])
		resource_data[i] = resource
	return resource_data
