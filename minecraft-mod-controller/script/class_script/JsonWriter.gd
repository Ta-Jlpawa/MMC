extends RefCounted
## 写入JSON文件的类(自定义类)
class_name JsonWriter


## 将 Resource 转换为 Dictionary (可被 JSON.stringify 序列化)[br]
## 支持嵌套的 Resource、Array 和 Dictionary
static func resource_to_dict(res: Resource) -> Dictionary:
	if not res:
		return {}
	
	var dict := {}
	var properties := res.get_property_list()
	
	for prop in properties:
		# 仅提取脚本中定义的变量和 @export 导出的属性
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var key: String = prop.name
			var value = res.get(key)
			dict[key] = _serialize_value(value)
			
	return dict


## 将数据写入 JSON 文件 (完全覆盖原内容)[br]
## path: 写入路径[br]
## data: 要写入的数据 (Array, Dictionary, 或 Resource)[br]
## indent: 缩进样式，默认用制表符 "\t" 美化排版，设为 "" 表示压缩格式
static func write_json(path: String, data: Variant, indent: String = "\t") -> Error:
	# 如果传入的是 Resource，自动转换
	if data is Resource:
		data = resource_to_dict(data)
		
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		var err := FileAccess.get_open_error()
		printerr("ERROR: [JsonWriter] 打开文件进行写入失败: ", path, " 错误码: ", err)
		return err
		
	var json_string := JSON.stringify(data, indent)
	file.store_string(json_string)
	file.close()
	return OK


## 将数据追加到 JSON 文件中 (不覆盖原内容)[br]
## 如果原 JSON 是列表 [ ... ]：传入单条数据会 append 进列表，传入列表会合并列表[br]
## 如果原 JSON 是字典 { ... }：传入字典会进行键值合并 (同名 key 会被新数据覆盖)
static func append_json(path: String, new_data: Variant, indent: String = "\t") -> Error:
	# 如果追加的是 Resource，自动转换为 Dictionary
	if new_data is Resource:
		new_data = resource_to_dict(new_data)
		
	var existing_data: Variant = null
	
	# 1. 尝试读取已存在的 JSON 文件
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			var content := file.get_as_text().strip_edges()
			file.close()
			
			if not content.is_empty():
				var json := JSON.new()
				var parse_err := json.parse(content)
				if parse_err == OK:
					existing_data = json.data
				else:
					printerr("ERROR: [JsonWriter] 原文件解析失败，路径: ", path, " 错误: ", json.get_error_message())
					return parse_err

	# 2. 根据原文件结构与新数据类型进行合并
	var final_data: Variant
	
	if existing_data == null:
		# 文件不存在或为空：直接使用新数据
		final_data = new_data
	elif existing_data is Array:
		# 原内容是 JSON 列表 [ ... ]
		if new_data is Array:
			existing_data.append_array(new_data)
		else:
			existing_data.append(new_data)
		final_data = existing_data
	elif existing_data is Dictionary:
		# 原内容是 JSON 字典 { ... }
		if new_data is Dictionary:
			# 字典合并：新数据覆盖旧数据的同名键
			existing_data.merge(new_data, true)
			final_data = existing_data
		else:
			printerr("ERROR: [JsonWriter] 追加失败：原 JSON 为字典格式，但传入的新数据非字典类型。")
			return ERR_INVALID_DATA
	else:
		printerr("ERROR: [JsonWriter] 追加失败：原文件顶层既不是列表也不是字典。")
		return ERR_INVALID_DATA

	# 3. 重新写入文件
	return write_json(path, final_data, indent)


## 内部方法：递归序列化处理嵌套的 Resource、Array 和 Dictionary[br]
## 被 func resource_to_dict(res: Resource) -> Dictionary 调用
static func _serialize_value(val: Variant) -> Variant:
	if val is Resource:
		return resource_to_dict(val)
	elif val is Array:
		var new_arr := []
		for item in val:
			new_arr.append(_serialize_value(item))
		return new_arr
	elif val is Dictionary:
		var new_dict := {}
		for k in val:
			new_dict[k] = _serialize_value(val[k])
		return new_dict
	else:
		return val
