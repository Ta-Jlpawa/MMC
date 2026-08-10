extends RefCounted
## 模组信息读取器
class_name ModReader


## 读取模组信息
static func read_mod_information(path: String) -> ModData:
	var reader = ZIPReader.new()
	var err = reader.open(path)
	if err != OK:
		return null
	
	var res: PackedByteArray = []
	var mod_data: ModData = null
	if reader.file_exists(GameConfig.NEOFORGE_MOD_INFORMATION_PATH): # NeoForge
		res = reader.read_file(GameConfig.NEOFORGE_MOD_INFORMATION_PATH)
		mod_data = parse_mod_toml_neoforge(res)
		
	elif reader.file_exists(GameConfig.FABRIC_MOD_INFORMATION_PATH): # Fabric 
		res = reader.read_file(GameConfig.FABRIC_MOD_INFORMATION_PATH)
		mod_data = parse_mod_json_fabric(res)
	
	reader.close()
	return mod_data


static func parse_mod_toml_neoforge(data: PackedByteArray) -> ModData:
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


static func parse_mod_json_fabric(data: PackedByteArray) -> ModData:
	var content: String = data.get_string_from_utf8()
	var mod_data: ModData = ModData.new()
	var result = JSON.parse_string(content)
	if result == null:
		printerr("ERROR: 模组信息JSON解析失败")
		return null
	
	mod_data.infomation.name = result.get("name", result.get("id", "未知模组"))
	mod_data.infomation.author = ", ".join(result.get("authors", ["未知作者"]))
	mod_data.infomation.description = result.get("description", "")
	mod_data.infomation.mc_version = result.get("depends", {}).get("minecraft", "未知版本")
	mod_data.infomation.mod_version = result.get("version", "未知模组版本")
	mod_data.infomation.modloader = "Fabric"
	mod_data.infomation.icon_path = ""
	
	return mod_data
