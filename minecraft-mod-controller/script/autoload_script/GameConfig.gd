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
	"moddata_parse": "", # 模组信息获取方式 "NOPARSE"不获取 "FILEPARSE"解析文件获取 "HTTPGET"访问外部API获取
	"is_first_execute": true, # 是否是第一次运行
	"file_dialog_last_dir_mod": "" # 模组选择框最后成功选择的位置
}


func _ready() -> void:
	pass
