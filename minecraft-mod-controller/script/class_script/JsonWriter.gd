extends RefCounted
## 写入JSON文件的类(自定义类)
class_name JsonWriter


## 尝试将资源内容转换为JSON格式并保存
static func save_res_to_json(path: String, res: Variant) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	
	var json_string: String = JSON.stringify(res, "\t")
	
	file.store_string(json_string)
	file.close()
