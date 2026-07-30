extends Control

@export var sideBar: SideBarUI = null
@export var all_ui: Array[Node] = []

var show_ui: Control = null


func _ready() -> void:
	get_tree().get_root().files_dropped.connect(_on_file_dropped)
	sideBar.option_selected.connect(_on_sidebar_button_pressed)
	
	show_ui = all_ui[0] #初始显示的UI
	show_ui.show()


func _on_sidebar_button_pressed(index: int) -> void:
	show_ui.hide()
	show_ui = all_ui[index]
	show_ui.show()
	print("INFO: UI %s 被选择" % index)



## 处理从外部拖放的文件
func _on_file_dropped(file_path: PackedStringArray) -> void:
	print(file_path)
