extends InformationUIObject
class_name ModObject

signal object_selected(object: Node) ## 组件被选中
signal object_unselected(object: Node) ## 组件取消选中

@export var panel: PanelContainer
@export var title_label: RichTextLabel
@export var author_label: Label
@export var content_label: RichTextLabel
@export var mcver_label: Label
@export var modver_label: Label

## 状态
var state: State = State.NORMAL:
	set(value):
		panel.state_toggled(value)
		state = value
var id: String = "" ## ID,对应一个信息的ID


func _ready() -> void:
	pass


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if state == InformationUIObject.State.NORMAL:
				state = InformationUIObject.State.CHOICE
				object_selected.emit(self)
			else:
				state = InformationUIObject.State.NORMAL
				object_unselected.emit(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("[ModObject] 右键逻辑暂未实现")
			## TODO: 右键查看信息逻辑


func set_data(node_id: String, title: String, author: String, content: String, mc_version: String, mod_version: String) -> void:
	id = node_id
	title_label.text = title
	author_label.text = author
	content_label.text = content
	mcver_label.text = mc_version
	modver_label.text = mod_version


## 取消选择
func unselected() -> void:
	state = InformationUIObject.State.NORMAL
	object_unselected.emit(self)


## 显示模组信息
func show_information() -> void:
	print("INFO: [ModObject] 该方法待实现")
	##TODO: 添加弹窗显示信息逻辑
	
