extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



## 测试_执行C++
func _execute_cpp() -> void:
	UIManager.show_warning_popup(GameConfig.WarningType.DESTRUCTIVE, "毁灭性错误")
	#var output: Array
	#OS.execute(GameManager.base_dir.path_join("Tool/Minecraft_Mod_Controller.exe"), [], output)
	#print(output)
