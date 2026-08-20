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
		mod_data = parse_mod_forge_toml(bytes)
	
	# Fabric 模组
	elif reader.file_exists("fabric.mod.json"): 
		var bytes = reader.read_file("fabric.mod.json")
		mod_data = parse_mod_fabric_json(bytes)
	
	# Forge 模组
	elif reader.file_exists("META-INF/mods.toml"): 
		var bytes = reader.read_file("META-INF/mods.toml")
		mod_data = parse_mod_forge_toml(bytes)
	
	# Legacy Forge 模组
	elif reader.file_exists("mcmod.info"):
		var bytes = reader.read_file("mcmod.info")
		mod_data = parse_mcmod_info(bytes)
	
	reader.close()
	return mod_data


## 解析 Forge / NeoForge TOML 格式
## TODO: 需要修改逻辑
static func parse_mod_forge_toml(data: PackedByteArray) -> ModData:
	var content: String = data.get_string_from_utf8()
	var mod_data: ModData = ModData.new()
	var result = Toml.parse_string(content)
	
	var mods: Dictionary = Toml.use_index_find_dict_in_arraytable(result, "mods", 0)
	var minecraft_data: Dictionary = Toml.use_kv_find_dict_in_arraytable(result, "dependencies.%s" % mods["modId"], "modId", "minecraft")
	
	mod_data.infomation.name = mods.get("displayName", mods.get("modId", "未知模组"))
	mod_data.infomation.author = mods.get("authors", "未知作者")
	mod_data.infomation.description = mods.get("description", "")
	mod_data.infomation.mc_version = minecraft_data.get("versionRange", "未知版本") # TODO: 实现根据文件名称猜测mc版本的逻辑
	mod_data.infomation.mod_version = mods.get("version", "未知模组版本") # TODO: 实现根据文件名称猜测mod版本的逻辑
	mod_data.infomation.modloader = "NeoForge"
	mod_data.infomation.icon_path = ""
	
	return mod_data


## 解析 fabric (fabric.mod.json)
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
		mod_data.infomation.mod_version = mod_dict.get("version", "Unknown")
		mod_data.infomation.mc_version = mod_dict.get("mcversion", "Unknown")
		mod_data.infomation.description = mod_dict.get("description", "No description provided.")
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
