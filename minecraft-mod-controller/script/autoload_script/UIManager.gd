extends Node

var popup_rootnode: Node = null
var popup_stack: Array[BasePopupUI] = []

signal popup_finish() ## 顶部弹窗被关闭时触发
signal popup_choose(data: String) ## 顶部弹窗的选项被选择时触发


func _ready() -> void:
	self.popup_finish.connect(close_top_popup)


func show_warning_popup(warn_type: GameConfig.WarningType, content: String) -> void:
	var scene: PackedScene = preload("uid://i3ka4d43ttp3")
	var popup: WarningPopup = scene.instantiate()
	popup.set_popup_data(warn_type, content)
	'''
	popup.anchor_left = 0.5
	popup.anchor_right = 0.5
	popup.anchor_top = 0.5
	popup.anchor_bottom = 0.5
	var texture_size = popup.get_size()
	popup.offset_left = -texture_size.x / 2
	popup.offset_right = texture_size.x / 2
	popup.offset_top = -texture_size.y / 2
	popup.offset_bottom = texture_size.y / 2'''
	popup_rootnode.add_child(popup)
	popup_stack.append(popup)


func close_top_popup() -> void:
	var popup: BasePopupUI = popup_stack.pop_back()
	popup.queue_free()


# 工具
## 设置根节点
func set_root_node(node: Node) -> void:
	popup_rootnode = node
