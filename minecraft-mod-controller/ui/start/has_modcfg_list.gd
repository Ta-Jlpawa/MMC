extends ScrollContainer


@export var modConfigObjStyle: PackedScene = null

var modcfg_data: Array = []


func _ready() -> void:
	generate_modcfg_object()


## 动态生成 模组配置信息 UI组件
func generate_modcfg_object() -> void:
	for i in GameManager.modcfg_data:
		var obj: ModConfigObject = modConfigObjStyle.instantiate()
		#obj.set_data(i.name)
