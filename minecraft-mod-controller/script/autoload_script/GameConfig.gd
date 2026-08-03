extends Node

## 警告类型
enum WarningType{
	DESTRUCTIVE,
	ALERT, ## 严重错误
	ERROR, ## 错误
	WARNING, ## 警告
	NOTICE, ## 提醒
	INFO ## 正常
}

const FABRIC_MOD_INFORMATION_PATH: String = "fabric.mod.json" ## Fabric模组信息文件在模组中的位置
const NEOFORGE_MOD_INFORMATION_PATH: String = "META-INF/neoforge.mods.toml" ## Neoforge模组信息文件在模组中的位置
## 默认设置模版
const SETTING_COPY: Dictionary = {
	"is_first_execute": true,
	"file_dialog_last_dir_mod": ""
}


func _ready() -> void:
	pass
