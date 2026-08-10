extends ScrollContainer
## 组件，用于获取并按条显示模组配置信息
class_name HasModConfigList


@export var modConfigObjStyle: PackedScene = null
@export var generateRootNode: Node = null


func _ready() -> void:
	generate_modcfg_object(GameManager.modcfg_data)


## 动态生成 模组配置信息 UI组件，组件信息应当来源于 GameManager.modcfg_data
func generate_modcfg_object(data: Dictionary[String, ModConfigData]) -> void:
	for i in data:
		var res: ModConfigData = data[i]
		var obj: ModConfigObject = modConfigObjStyle.instantiate()
		obj.set_data(res.infomation.display_name, res.infomation.description, res.infomation.mc_version, res.infomation.display_name)
		generateRootNode.add_child(obj)


## 清除所有 模组配置信息 UI组件
func clear_modcfg_object() -> void:
	var child = generateRootNode.get_children()
	for node in child:
		node.queue_free()
		

## 重新加载 模组配置信息 UI组件，会清除已有的组件
func reload_modcfg_object(data: Dictionary[String, ModConfigData]):
	clear_modcfg_object()
	generate_modcfg_object(data)
	print("INFO: 重载模组配置信息")
