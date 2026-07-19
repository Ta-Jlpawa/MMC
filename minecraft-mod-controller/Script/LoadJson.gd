## 加载JSON文件的类(自定义类)
class_name LoadJson

## 读取一个json文件并转换为字典或列表
func load_json_to_dict(path: String) -> Variant:

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("无法打开 JSON 文件: %s" % path)
		return {}

	var text = file.get_as_text()
	file.close()

	var result = JSON.parse_string(text)
	if result == null:
		push_error("JSON 解析失败")
		return {}
	
	if result is Array:
		var data: Array = result
		return data
	else:
		var data: Dictionary = result
		return data
