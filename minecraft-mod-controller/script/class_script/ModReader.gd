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
		mod_data = prase_mod_toml(res)
		
	elif reader.file_exists(GameConfig.FABRIC_MOD_INFORMATION_PATH): # Fabric 
		res = reader.read_file(GameConfig.NEOFORGE_MOD_INFORMATION_PATH)
		mod_data = prase_mod_json(res)
	
	reader.close()
	return mod_data


static func prase_mod_toml(data: PackedByteArray) -> ModData:
	var content: String = data.get_string_from_utf8()
	var mod_data: ModData = null
	return mod_data


static func prase_mod_json(data: PackedByteArray) -> ModData:
	var content: String = data.get_string_from_utf8()
	var mod_data: ModData = null
	var result = JSON.parse_string(content)
	if result == null:
		printerr("ERROR: 模组信息JSON解析失败")
		return null
	mod_data.name = result["name"]
	Array
	# TODO: 模组解析逻辑
	for i: String in result["authors"]:
		mod_data.author += i
	mod_data.description = result["description"]
	
	return mod_data
