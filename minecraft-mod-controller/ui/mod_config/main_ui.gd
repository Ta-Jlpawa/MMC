extends Control

@export var hasModConfigList: HasModConfigList = null

var object_list: Array[Node] = []
var object_select_id: Array[String] = []

func generate_mod_object() -> void:
	for old_node in object_list:
		old_node.disconnect("object_selected", _object_selected)
		old_node.disconnect("object_unselected", _object_unselected)
	object_list.clear()
	object_select_id.clear()
	hasModConfigList.reload_modcfg_object(GameManager.modcfg_data)
	object_list = hasModConfigList.get_nodes()
	for node in object_list:
		node.object_selected.connect(_object_selected)
		node.object_unselected.connect(_object_unselected)


func get_selected_node() -> Array[String]:
	print("INFO: [ModConfigUI.main_ui] 获取选中的配置 %s" % [object_select_id])
	return object_select_id


func unselected_all():
	object_select_id.clear()
	for node in object_list:
		node.unselected()


func _object_selected(node: Node) -> void:
	object_select_id.append(node.id)
	

func _object_unselected(node: Node) -> void:
	if object_list.is_empty(): return
	object_select_id.erase(node.id)
