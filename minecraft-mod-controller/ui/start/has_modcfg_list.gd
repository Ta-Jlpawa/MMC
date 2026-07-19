extends ScrollContainer


var modcfg_data: Array = []


func _ready() -> void:
	create_modcfg_object()


func create_modcfg_object() -> void:
	modcfg_data = GameManager.json_loader.load_json_to_dict(GameManager.base_dir.path_join("data/has_modcfg_data.json"))
	print("INFO: 读取modcfg_data: %s", modcfg_data)
