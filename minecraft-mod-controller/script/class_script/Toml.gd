extends RefCounted
## 为本地提取 NeoForge 与 Forge 模组信息编写的简易 TOML 解析类
class_name Toml

## @deprecated
## 该方法已废弃
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
	

## 解析 Toml 文件内容
static func parse(toml_text: String) -> Dictionary:
	var root: Dictionary = {} # 根表
	var current_dict: Dictionary = root # 当前正在修改的对象
	var lines: PackedStringArray = toml_text.split("\n")
	
	var in_multiline_str: bool= false # 是否多行文本模式
	var multiline_key: String = ""
	var multiline_val: String= ""
	var quote_type: String= ""

	for line in lines:
		line = line.strip_edges()

		# 处理多行字符串块
		if in_multiline_str:
			if line.ends_with(quote_type):
				multiline_val += line.left(line.length() - quote_type.length())
				current_dict[multiline_key] = multiline_val.strip_edges()
				in_multiline_str = false
			else:
				multiline_val += line + "\n"
			continue

		# 忽略空行与行首注释
		if line.is_empty() or line.begins_with("#"):
			continue

		# 匹配 Section Headers: [[array_table]] 或 [table]
		if line.begins_with("["):
			if line.begins_with("[[") and line.ends_with("]]"):
				var path := line.substr(2, line.length() - 4).strip_edges()
				current_dict = _get_or_create_array_table(root, path)
			elif line.ends_with("]"):
				var path := line.substr(1, line.length() - 2).strip_edges()
				current_dict = _get_or_create_table(root, path)
			continue

		# 匹配 kv 键值对
		var eq_idx := line.find("=")
		if eq_idx != -1:
			var key := line.left(eq_idx).strip_edges()
			var val_str := line.substr(eq_idx + 1).strip_edges()

			# 剔除行尾注释
			val_str = _strip_comment(val_str)

			# 检查是否开启多行文本
			if val_str.begins_with("'''") or val_str.begins_with("\"\"\""):
				quote_type = val_str.left(3)
				if val_str.ends_with(quote_type) and val_str.length() > 3:
					current_dict[key] = val_str.substr(3, val_str.length() - 6)
				else:
					in_multiline_str = true
					multiline_key = key
					multiline_val = val_str.substr(3) + "\n"
				continue

			current_dict[key] = _parse_value(val_str)

	return root


static func _get_or_create_table(root: Dictionary, path_str: String) -> Dictionary:
	var parts := path_str.split(".")
	var curr: Dictionary = root
	for part in parts:
		var p := part.strip_edges()
		if not curr.has(p):
			curr[p] = {}
		elif curr[p] is Array and not curr[p].is_empty():
			curr = curr[p][-1] # 引用数组表格的最新一项
			continue
		curr = curr[p]
	return curr


static func _get_or_create_array_table(root: Dictionary, path_str: String) -> Dictionary:
	var parts := path_str.split(".")
	var curr: Dictionary = root
	
	# 逐级创建父节点
	for i in range(parts.size() - 1):
		var p := parts[i].strip_edges()
		if not curr.has(p):
			curr[p] = {}
		curr = curr[p]

	var last_part := parts[-1].strip_edges()
	if not curr.has(last_part) or not curr[last_part] is Array:
		curr[last_part] = []
	
	var new_dict := {}
	curr[last_part].append(new_dict)
	return new_dict


static func _strip_comment(val: String) -> String:
	var in_quotes := false
	var quote_char := ""
	for i in range(val.length()):
		var c := val[i]
		if not in_quotes and (c == '"' or c == "'"):
			in_quotes = true
			quote_char = c
		elif in_quotes and c == quote_char:
			in_quotes = false
		elif not in_quotes and c == '#':
			return val.left(i).strip_edges()
	return val


## 解析值
static func _parse_value(value: String) -> Variant:
	value = value.strip_edges()
	# 字符串
	if (value.begins_with("\"") and value.ends_with("\""))\
	or (value.begins_with("'") and value.ends_with("'")): return value.substr(1, value.length() - 2)
	# 布尔值
	if value == "true": return true
	if value == "false": return false
	# 数字
	if value.is_valid_int(): return value.to_int()
	if value.is_valid_float(): return value.to_float()
	# 数组 [...]
	if value.begins_with("[") and value.ends_with("]"):
		var arr_text := value.substr(1, value.length() - 2).strip_edges()
		if arr_text.is_empty(): return []
		var arr: Array = []
		for item in arr_text.split(","):
			var clean := item.strip_edges()
			if not clean.is_empty():
				arr.append(_parse_value(clean))
		return arr
	return value


## @deprecated
## 该方法已废弃
static func get_key_and_value(line: String) -> Array:
	var data: PackedStringArray = line.split("=")
	if data.size() < 2: return ["null", "null"] # 此处在测试时应当删除，以便用来兼容更多的模组
	var key = data[0].strip_edges()
	var value = data[1].strip_edges()
	value = _parse_value(value)
	return [key, value]


## @deprecated
## 该方法已废弃
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


## @deprecated
## 该方法已废弃
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
