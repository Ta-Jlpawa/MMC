extends RefCounted
## 模组配置信息读取器，包含写入文件相关方法
class_name ModConfigReader


## 读取指定目录下的模组路径
## 返回形如 <文件名> : <文件全局路径> 的字典
static func read_mod_from_dir(path: String) -> Dictionary[String, String]:
	var dir_path: String = path
	var files: PackedStringArray = DirAccess.get_files_at(dir_path)
	var jar_path: Dictionary[String, String] = {}
	for i in files:
		if i.get_extension() == "jar":
			jar_path[i] = dir_path.path_join(i)
	return jar_path


## TODO: 该方法未完成，解析一个没有导入的整合包似乎是一个艰巨的任务..
static func read_mod_from_zip(path: String) -> Array[String]:
	var reader = ZIPReader.new()
	var err = reader.open(path)
	if err != OK:
		printerr("ERROR: [ModConfigReader] 读取zip文件失败")
		return []
	
	var mod: Array[String] = []
	
	reader.close()
	return mod
