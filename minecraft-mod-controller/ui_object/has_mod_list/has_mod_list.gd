extends ScrollContainer
## 组件，用于获取并按条显示模组信息
class_name HasModList


@export var modObjStyle: PackedScene = null
@export var generateRootNode: Node = null


func _ready() -> void:
	generate_modcfg_object(GameManager.mod_data)


## 动态生成 模组信息 UI组件，组件信息应当来源于 GameManager.mod_data
func generate_modcfg_object(data: Array[ModData]) -> void:
	for i in data:
		var obj: ModObject = modObjStyle.instantiate()
		obj.set_data(i.name, i.author, i.description, i.mc_version, i.mod_version)
		generateRootNode.add_child(obj)


## 清除所有 模组配置信息 UI组件
func clear_modcfg_object() -> void:
	var child = generateRootNode.get_children()
	for node in child:
		node.queue_free()
		

## 重新加载 模组配置信息 UI组件，会清除已有的组件
func reload_modcfg_object(data: Array[ModData]):
	clear_modcfg_object()
	generate_modcfg_object(data)
	print("INFO: 重载模组配置信息")
