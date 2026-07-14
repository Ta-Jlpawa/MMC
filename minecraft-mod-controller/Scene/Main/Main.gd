extends Node


var base_dir:String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://..")
	else:
		OS.get_data_dir()
		base_dir = OS.get_executable_path().get_base_dir()
	var output: Array
	OS.execute(base_dir.path_join("Tool/Minecraft_Mod_Controller.exe"), [], output)
	print(base_dir)
	print(output)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
