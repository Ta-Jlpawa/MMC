extends Control


signal is_continue(action: bool)

@export var hasModListNode: HasModList = null
@export var richCheckButton: RichCheckButton = null


func generate_mod_object(data: Dictionary[String, ModData]) -> void:
	richCheckButton.reset()
	hasModListNode.reload_mod_object(data)


## 获取可选项的状态
func get_option_state() -> bool:
	return richCheckButton.get_state()


func _on_continue_pressed():
	self.is_continue.emit(true)
	

func _on_back_to_mainui_pressed():
	self.is_continue.emit(false)
