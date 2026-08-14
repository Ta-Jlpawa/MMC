extends ScrollContainer
## 组件，用于获取并按条显示模组信息
class_name HasModList


@export var modObjStyle: PackedScene = null
@export var generateRootNode: Node = null


func _ready() -> void:
	pass


## 动态生成 模组信息 UI组件，组件需要传入生成信息
## 不会清除已有的组件
func generate_mod_object(data: Dictionary[String, ModData]) -> void:
	for i in data:
		var value = data[i]
		var obj: ModObject = modObjStyle.instantiate()
		obj.set_data(value.infomation.name, value.infomation.author, value.infomation.description, value.infomation.mc_version, value.infomation.mod_version)
		generateRootNode.add_child(obj)


## 清除所有 模组配置信息 UI组件
func clear_mod_object() -> void:
	var child = generateRootNode.get_children()
	for node in child:
		node.queue_free()
		

## 重新加载 模组配置信息 UI组件
## 会自动清除已有的组件
func reload_mod_object(data: Dictionary[String, ModData]):
	clear_mod_object()
	generate_mod_object(data)
	print("INFO: 重载模组配置信息")
