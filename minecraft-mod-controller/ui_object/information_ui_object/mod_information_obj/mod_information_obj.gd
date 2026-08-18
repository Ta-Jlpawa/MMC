extends InformationUIObject
class_name ModObject

@export var button: Button
@export var title_label: RichTextLabel
@export var author_label: Label
@export var content_label: RichTextLabel
@export var mcver_label: Label
@export var modver_label: Label


func _ready() -> void:
	pass
	

func set_data(title: String, author: String, content: String, mc_version: String, mod_version: String) -> void:
	title_label.text = title
	author_label.text = author
	content_label.text = content
	mcver_label.text = mc_version
	modver_label.text = mod_version


## 显示配置信息
func show_information() -> void:
	print("INFO: [ModConfigObject] 该方法待实现")
	##TODO: 添加弹窗显示信息逻辑
	
	
