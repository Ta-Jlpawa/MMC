extends RefCounted
## 模组信息读取器
class_name ModReader


## 读取模组信息
static func read_mod_information(path: String) -> ModData:
	var reader = ZIPReader.new()
	var err = reader.open(path)
	if err != OK:
		return null
	
	var mod_data: ModData = null
	
	# NeoForge 模组
	if reader.file_exists("META-INF/neoforge.mods.toml"): 
		var bytes = reader.read_file("META-INF/neoforge.mods.toml")
		mod_data = parse_mod_forge_toml(bytes, "NeoForge")
	
	# Fabric 模组
	elif reader.file_exists("fabric.mod.json"): 
		var bytes = reader.read_file("fabric.mod.json")
		mod_data = parse_mod_fabric_json(bytes)
	
	# Forge 模组
	elif reader.file_exists("META-INF/mods.toml"): 
		var bytes = reader.read_file("META-INF/mods.toml")
		mod_data = parse_mod_forge_toml(bytes, "Forge")
	
	# Legacy Forge 模组
	elif reader.file_exists("mcmod.info"):
		var bytes = reader.read_file("mcmod.info")
		mod_data = parse_mcmod_info(bytes)
	
	reader.close()
	return mod_data


## 解析 Forge / NeoForge TOML 格式
static func parse_mod_forge_toml(data: PackedByteArray, mod_loader: String) -> ModData:
	var content: String = data.get_string_from_utf8()
	var mod_data: ModData = ModData.new()
	var toml_dict = Toml.parse(content)
	#var mods: Dictionary = Toml.use_index_find_dict_in_arraytable(toml_dict, "mods", 0)
	#var minecraft_data: Dictionary = Toml.use_kv_find_dict_in_arraytable(toml_dict, "dependencies.%s" % mods["modId"], "modId", "minecraft")
	# 判定加载器类型
	mod_data.infomation.modloader = mod_loader
	# 从 [[mods]] 表格数组中提取模组主信息
	if toml_dict.has("mods") and toml_dict["mods"] is Array and not toml_dict["mods"].is_empty():
		var mod_dict: Dictionary = toml_dict["mods"][0]
		mod_data.infomation.id = str(mod_dict.get("modId", ""))
		mod_data.infomation.name = str(mod_dict.get("displayName", mod_data.infomation.id))
		mod_data.infomation.mod_version = str(mod_dict.get("version", "未知模组版本"))
		mod_data.infomation.description = str(mod_dict.get("description", ""))
		mod_data.infomation.author = _parse_authors(mod_dict.get("authors", []))
	# 从 [[dependencies]] 节点提取关联的 Minecraft 版本
	var mc_ver := _extract_mc_version_from_deps(toml_dict, mod_data.infomation.id)
	if not mc_ver.is_empty():
		mod_data.infomation.mc_version = mc_ver
	# mod icon 路径
	## TODO: 需要实现图像提取，缓存与读取逻辑
	mod_data.infomation.icon_path = ""
	
	return mod_data


## 解析 Fabric (fabric.mod.json)
static func parse_mod_fabric_json(bytes: PackedByteArray) -> ModData:
	var mod_data: ModData = ModData.new()
	var json_data = JSON.parse_string(bytes.get_string_from_utf8())
	if json_data == null:
		printerr("ERROR: 模组信息JSON解析失败")
		return null
	
	mod_data.infomation.id = json_data.get("id", "")
	mod_data.infomation.name = json_data.get("name", json_data.get("id", "未知模组"))
	mod_data.infomation.description = json_data.get("description", "")
	mod_data.infomation.mod_version = json_data.get("version", "未知模组版本")
	mod_data.infomation.modloader = "Fabric"
	mod_data.infomation.icon_path = ""
	
	mod_data.infomation.author = _parse_authors(json_data.get("authors", []))
	#mod_data.infomation.mc_version = json_data.get("depends", {}).get("minecraft", "未知版本")
	if json_data.has("depends") and json_data["depends"] is Dictionary:
		var depends: Dictionary = json_data["depends"]
		if depends.has("minecraft"):
			var mc_val = depends["minecraft"]
			mod_data.infomation.mc_version = str(mc_val[0]) if mc_val is Array and mc_val.size() > 0 else str(mc_val)
	
	return mod_data
	

## 解析 Legacy Forge (mcmod.info)
static func parse_mcmod_info(bytes: PackedByteArray) -> ModData:
	var mod_data: ModData = ModData.new()
	var json_data = JSON.parse_string(bytes.get_string_from_utf8())
	
	var mod_dict: Dictionary = {}

	if json_data is Array and json_data.size() > 0:
		mod_dict = json_data[0]
	elif json_data is Dictionary:
		mod_dict = json_data["modList"][0] if json_data.has("modList") and json_data["modList"].size() > 0 else json_data

	if not mod_dict.is_empty():
		mod_data.infomation.id = mod_dict.get("modid", "")
		mod_data.infomation.name = mod_dict.get("name", mod_dict.get("modid", "Unknown Mod"))
		mod_data.infomation.description = mod_dict.get("description", "No description provided.")
		mod_data.infomation.mc_version = mod_dict.get("mcversion", "Unknown")
		mod_data.infomation.mod_version = mod_dict.get("version", "Unknown")
		mod_data.infomation.modloader = "Forge"
		mod_data.infomation.author = _parse_authors(mod_dict.get("authorList", mod_dict.get("authors", [])))

	return mod_data


## 辅助方法，用于解析作者名称
static func _parse_authors(raw_authors) -> Array[String]:
	var res: Array[String] = []
	if raw_authors is String:
		for a: String in raw_authors.split(","):
			var trimmed = a.strip_edges()
			if not trimmed.is_empty():
				res.append(trimmed)
	elif raw_authors is Array:
		for item in raw_authors:
			if item is String:
				res.append(item)
			elif item is Dictionary and item.has("name"):
				res.append(str(item["name"]))
	return res


## 辅助方法，专用于从 TOML 字典结构中检索 Minecraft 版本约束
static func _extract_mc_version_from_deps(toml_dict: Dictionary, target_mod_id: String) -> String:
	if not toml_dict.has("dependencies"):
		return ""

	var deps = toml_dict["dependencies"]

	# 情况 A: dependencies 为字典（如 [[dependencies.examplemod]] 结构）
	if deps is Dictionary:
		# 优先匹配当前模组 ID 的依赖项
		if not target_mod_id.is_empty() and deps.has(target_mod_id) and deps[target_mod_id] is Array:
			var ver := _find_mc_in_dep_array(deps[target_mod_id])
			if not ver.is_empty():
				return ver
		
		# 回退遍历所有子依赖节点
		for mod_key in deps:
			if deps[mod_key] is Array:
				var ver := _find_mc_in_dep_array(deps[mod_key])
				if not ver.is_empty():
					return ver

	# 情况 B: dependencies 为数组（早期/扁平 [[dependencies]] 结构）
	elif deps is Array:
		return _find_mc_in_dep_array(deps)

	return ""


## 辅助方法，_extract_mc_version_from_deps方法的辅助方法
static func _find_mc_in_dep_array(dep_array: Array) -> String:
	for dep in dep_array:
		if dep is Dictionary and str(dep.get("modId", "")) == "minecraft":
			return str(dep.get("versionRange", ""))
	return ""
