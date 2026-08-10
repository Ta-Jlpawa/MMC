extends RefCounted
## 模组配置信息读取器
class_name ModConfigReader


## 
static func read_mod_from_dir(path: String) -> Array[String]:
	DirAccess.get_files_at(path)


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
