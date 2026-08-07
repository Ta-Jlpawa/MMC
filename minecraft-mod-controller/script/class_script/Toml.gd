extends RefCounted
class_name Toml


static func parse_string(data: String) -> Dictionary:
	var result: Dictionary = {} # 根表
	var current_object: Dictionary = result # 当前正在修改的对象
	var lines: PackedStringArray = data.split("\n")
	
	for line in lines:
		line = line.strip_edges()
		
		if line.is_empty() or line.begins_with("#"): # 注释
			continue
		elif line.begins_with("[[") and line.ends_with("]]"): # 表数组
			current_object = result
			var table_name: PackedStringArray = line.substr(2, line.length() - 4).split(".")
			for i in table_name:
				if i == table_name[-1]: # 最后的数组
					if !current_object.has(i): # 如果是新数组
						current_object[i] = []
					current_object[i].append({})
					current_object = current_object[i][-1]
				else: # 嵌套表
					if !current_object.has(i): # 如果是新表
						current_object[i] = {}
					current_object = current_object[i]
		else: # 键值对
			var kv: Array = get_key_and_value(line)
			current_object[kv[0]] = kv[1]
	print(result)
	return result


static func parse_value(value: String) -> Variant:
	if value.begins_with("\"") and value.ends_with("\""): return value.substr(1, value.length() - 2)# 字符串
	if value == "true": return true # 布尔
	if value == "false": return false
	if value.is_valid_int(): return int(value) # 数字
	if value.is_valid_float(): return float(value)
	if value.begins_with("[") and value.ends_with("]"): # 数组
		var arr_text = value.substr(1, value.length() - 2)
		var arr=[]
		for item in arr_text.split(","):
			arr.append(parse_value(item.strip_edges()))
		return arr
	return value


static func get_key_and_value(line: String) -> Array:
	var data: PackedStringArray = line.split("=")
	if data.size() < 2: return ["null", "null"] # 此处在测试时应当删除，以便用来兼容更多的模组
	var key = data[0].strip_edges()
	var value = data[1].strip_edges()
	value = parse_value(value)
	return [key, value]


static func use_index_find_dict_in_arraytable(data: Dictionary, table_name: String, index: int) -> Dictionary:
	var current_object: Dictionary = data # 当前正在查找的对象
	var array: Array = []
	var parse_table_name: PackedStringArray = table_name.split(".")
	for i in parse_table_name:
		if i == parse_table_name[-1]:
			array = current_object[i]
			break
		current_object = current_object[i]
	print(array)
	return array[index]


static func use_kv_find_dict_in_arraytable(data: Dictionary, table_name: String, key: String, value: Variant) -> Dictionary:
	var current_object: Dictionary = data # 当前正在查找的对象
	var array: Array = []
	var parse_table_name: PackedStringArray = table_name.split(".")
	for i in parse_table_name:
		if i == parse_table_name[-1]:
			array = current_object[i]
			break
		current_object = current_object[i]
	for i: Dictionary in array:
		if i.has(key) and i[key] == value:
			return i
	return {}
