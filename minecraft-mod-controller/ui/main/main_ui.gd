extends Control


func _ready() -> void:
	get_tree().get_root().files_dropped.connect(_on_file_dropped)


func _process(delta: float) -> void:
	pass


## 处理从外部拖放的文件
func _on_file_dropped(file_path: PackedStringArray) -> void:
	print(file_path)
