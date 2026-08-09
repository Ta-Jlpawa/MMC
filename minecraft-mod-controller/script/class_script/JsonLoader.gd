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






## 从 JSON 文件中读取数据并递归转换为指定的 Resource 对象
## @param path: JSON 文件路径 (例如 "user://config.json")
## @param target: 可以是 Resource 的脚本 (如 Config)、类名字符串，或者是已初始化的 Resource 实例
## @return: 填充后的 Resource 对象；失败时返回 null
static func load_resource_from_json(path: String, target: Variant) -> Resource:
	if not FileAccess.file_exists(path):
		printerr("[JsonReader] 文件不存在: ", path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		printerr("[JsonReader] 打开文件失败: ", path)
		return null

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		printerr("[JsonReader] JSON 解析失败 [第 %d 行]: %s" % [json.get_error_line(), json.get_error_message()])
		return null

	var data = json.data
	if not data is Dictionary:
		printerr("[JsonReader] 顶级 JSON 数据必须是字典，才能映射到 Resource 属性！")
		return null

	# 确定目标 Resource 实例
	var res_instance: Resource = null
	if target is Script:
		res_instance = target.new()
	elif target is Resource:
		res_instance = target
	elif target is String:
		res_instance = _create_resource_by_type_name(target)
	
	if not res_instance:
		printerr("[JsonReader] 无法创建或识别目标 Resource 实例。")
		return null

	return dict_to_resource(data, res_instance)


## 将 Dictionary 递归转换为指定的 Resource 对象
static func dict_to_resource(dict: Dictionary, res: Resource) -> Resource:
	if not res or not dict:
		return res

	# 提取 Resource 的所有脚本变量
	var prop_map := {}
	for prop in res.get_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			prop_map[prop.name] = prop

	for key in dict:
		if not prop_map.has(key):
			# 如果 JSON 中的 key 在 Resource 里没有定义属性，自动跳过
			continue

		var prop_info: Dictionary = prop_map[key]
		var val = dict[key]
		
		# 递归解析并转换值
		var parsed_val = _convert_value(val, prop_info, res.get(key))
		res.set(key, parsed_val)

	return res


## 内部值转换逻辑
static func _convert_value(val: Variant, prop_info: Dictionary, current_val: Variant) -> Variant:
	if val == null:
		return null

	var prop_type: int = prop_info.get("type", TYPE_NIL)
	var hint_string: String = prop_info.get("hint_string", "")

	# 嵌套子资源对象 (TYPE_OBJECT)
	if prop_type == TYPE_OBJECT:
		if val is Dictionary:
			var sub_res: Resource = null
			if current_val is Resource:
				sub_res = current_val
			else:
				# 根据 @export 导出的 Resource 类型名自动实例化
				sub_res = _create_resource_by_type_name(hint_string)
			
			if sub_res:
				return dict_to_resource(val, sub_res)
		return val

	# 数组 (TYPE_ARRAY)
	elif prop_type == TYPE_ARRAY:
		if val is Array:
			var target_array := []
			# 获取强类型数组中的类型名称 (例如 Array[ConfigInformation] 中的 ConfigInformation)
			var element_class_name := _extract_array_element_class(hint_string)
			
			for item in val:
				if item is Dictionary and not element_class_name.is_empty():
					# 如果数组元素是字典，且声明了元素 Resource 类型，进行递归转换
					var elem_res := _create_resource_by_type_name(element_class_name)
					if elem_res:
						target_array.append(dict_to_resource(item, elem_res))
					else:
						target_array.append(item)
				else:
					target_array.append(item)
			return target_array

	# 字典 (TYPE_DICTIONARY)
	elif prop_type == TYPE_DICTIONARY:
		if val is Dictionary:
			return val

	# 数值类型转换修正 (JSON 的浮点数转 int)
	elif prop_type == TYPE_INT and val is float:
		return int(val)

	return val


## 根据类型名称 (class_name) 动态实例化 Resource
static func _create_resource_by_type_name(type_name: String) -> Resource:
	if type_name.is_empty():
		return null

	# 检查内置引擎类
	if ClassDB.class_exists(type_name):
		var obj = ClassDB.instantiate(type_name)
		if obj is Resource:
			return obj

	# 检查通过 class_name 声明的自定义脚本类
	for item in ProjectSettings.get_global_class_list():
		if item["class"] == type_name:
			var script = load(item["path"])
			if script and script.has_method("new"):
				var instance = script.new()
				if instance is Resource:
					return instance

	return null


## 从 Typed Array 的 hint_string 中解析出类的名称
## Godot 4 中的格式形如 "24/17:ConfigInformation" 或 "ConfigInformation"
static func _extract_array_element_class(hint_string: String) -> String:
	if hint_string.is_empty():
		return ""
	if ":" in hint_string:
		return hint_string.split(":")[-1]
	return hint_string
