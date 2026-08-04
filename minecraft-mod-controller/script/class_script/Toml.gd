extends RefCounted
class_name Toml


static func parse_string(data: String) -> Dictionary:
	var result: Dictionary = {}
	var current_section := ""
	var lines: Array[String] = data.split("\n")
	
	for line in lines:
		line = line.strip_edges()
		# TODO:完成toml解析
	
	return result
