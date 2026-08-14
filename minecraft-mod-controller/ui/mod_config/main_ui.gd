extends Control

@export var hasModConfigList: HasModConfigList = null


func generate_mod_object() -> void:
	hasModConfigList.reload_modcfg_object(GameManager.modcfg_data)
