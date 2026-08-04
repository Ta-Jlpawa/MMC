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
	var content: String = ""
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
	var mod_data: ModData = null
	var result = Toml.parse_string(content)
	return mod_data


static func parse_mod_json_fabric(data: PackedByteArray) -> ModData:
	var content: String = data.get_string_from_utf8()
	var mod_data: ModData = null
	var result = JSON.parse_string(content)
	if result == null:
		printerr("ERROR: 模组信息JSON解析失败")
		return null
	
	mod_data.name = result["name"]
	mod_data.author = ", ".join(result["authors"])
	mod_data.description = result["description"]
	mod_data.mc_version = result["depends"]["minecraft"]
	mod_data.mod_version = result["version"]
	mod_data.modloader = "Fabric"
	mod_data.icon_path = ""
	
	return mod_data
