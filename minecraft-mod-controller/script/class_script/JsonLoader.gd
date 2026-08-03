extends RefCounted
## 加载JSON文件的类(自定义类)
class_name JsonLoader

## 读取一个json文件并转换为字典或列表
static func load_json_to_data(path: String) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("无法打开 JSON 文件: %s" % path)
		return {}
	var result = JSON.parse_string(file.get_as_text())
	if result == null:
		push_error("JSON 解析失败")
		return {}
	if result is Array:
		var data: Array = result
		return data
	else:
		var data: Dictionary = result
		return data


## 读取一个json文件并转换为指定类型资源
static func load_json_to_res(path: String, type) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("无法打开 JSON 文件: %s" % path)
		return null
	var result = JSON.parse_string(file.get_as_text())
	if result == null:
		push_error("JSON 解析失败")
		return null
	if result is Array:
		var data: Array = dict_array_to_res(result, type)
		return data
	else:
		var data: Dictionary = dict_to_res(result, type)
		return data


## 读取一个字典并转换为指定类型的资源
static func dict_to_res(dict: Dictionary, type) -> Variant:
	var resource = type.new()
	for key in dict:
		if resource.get(key) != null:
			resource.set(key, dict[key])
	return resource


## 读取一个字典列表并转换为指定类型的资源列表
static func dict_array_to_res(array: Array, type) -> Array:
	var resource_array: Array = []
	for i in array:
		var resource = type.new()
		for key in i:
			if resource.get(key) != null:
				resource.set(key, i[key])
		resource_array.append(resource)
	return resource_array
