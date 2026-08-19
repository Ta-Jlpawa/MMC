extends RefCounted
class_name ModpackReader

# 解析结果的数据结构定义
class ModpackInfo:
	var name: String
	var version: String
	var mc_version: String
	var mod_loader: String
	var files: Array[Dictionary] # 包含 { "name": String, "url": String, "path": String, "project_id": int, "file_id": int }


## 读取并解析 .zip 整合包文件
## 返回的字典包含: name:整合包名称, version:整合包版本, mc_version:MC版本, files:整合包mod信息列表
## 整合包mod信息包含: name: 模组文件名(带后缀), path: 模组在整合包中的路径(实际没大用)
static func parse_zip(zip_path: String) -> Dictionary:
	var reader := ZIPReader.new()
	var err := reader.open(zip_path)
	if err != OK:
		push_error("无法打开 Zip 文件: %s (错误代码: %d)" % [zip_path, err])
		return {}

	var result := {
		"name": "Unknown Pack",
		"version": "1.0.0",
		"mc_version": "Unknown",
		"files": [] # 统一的下载列表
	}

	# 1. 优先检测 Modrinth 格式 (modrinth.index.json)
	if reader.file_exists("modrinth.index.json"):
		var json_bytes := reader.read_file("modrinth.index.json")
		_parse_modrinth(json_bytes.get_string_from_utf8(), result)
	# 2. 其次检测 CurseForge 格式 (manifest.json)
	elif reader.file_exists("manifest.json"):
		printerr("UNKNOWN: 未实现导入CurseForge格式的整合包")
		## TODO: 实现导入CurseForge格式的整合包
		#var json_bytes := reader.read_file("manifest.json")
		#_parse_curseforge(json_bytes.get_string_from_utf8(), result)
	else:
		push_error("未找到支持的整合包配置文件 (manifest.json 或 modrinth.index.json)")

	reader.close()
	return result

## 解析 Modrinth 格式整合包
static func _parse_modrinth(json_str: String, out_result: Dictionary) -> void:
	var json := JSON.new()
	if json.parse(json_str) != OK:
		return
	
	var data: Dictionary = json.data
	out_result["name"] = data.get("name", "Modrinth Pack")
	out_result["version"] = data.get("versionId", "1.0")
	out_result["mc_version"] = data.get("dependencies", {}).get("minecraft", "")

	for file in data.get("files", []):
		# 仅提取 mods 目录下的 jar 文件
		var path: String = file.get("path", "")
		var downloads: Array = file.get("downloads", [])
		if not downloads.is_empty():
			out_result["files"].append({
				"name": path.get_file(),
				"path": path, # 例如 "mods/sodium.jar"
				"url": downloads[0], # Direct CDN URL
				"size": file.get("fileSize", 0)
			})

## 解析 CurseForge 格式整合包
## TODO： 需要修改实现
static func _parse_curseforge(json_str: String, out_result: Dictionary) -> void:
	var json := JSON.new()
	if json.parse(json_str) != OK:
		return
		
	var data: Dictionary = json.data
	out_result["name"] = data.get("name", "CurseForge Pack")
	out_result["version"] = data.get("version", "1.0")
	
	var mc_info: Dictionary = data.get("minecraft", {})
	out_result["mc_version"] = mc_info.get("version", "")

	for file in data.get("files", []):
		var project_id: int = file.get("projectID", 0)
		var file_id: int = file.get("fileID", 0)
		
		out_result["files"].append({
			"name": "mod_%d_%d.jar" % [project_id, file_id],
			"path": "mods/mod_%d_%d.jar" % [project_id, file_id],
			"project_id": project_id,
			"file_id": file_id,
			# CurseForge 官方不直接在 manifest 里给 URL，
			# 需使用 CurseForge API 或第三方 Mirror API 换取真实 URL
			"url": "" 
		})
