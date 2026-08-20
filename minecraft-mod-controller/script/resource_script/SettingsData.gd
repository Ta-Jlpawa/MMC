extends Resource
## 设置的数据模型
class_name SettingsData


var minecraft_folder: String = "" ## 操控的MC文件夹位置
var file_dialog_last_dir_mod: String = "" ## 文件选择器(mod)最后一次成功打开的位置，用于优化文件打开操作，使其更加便捷
var is_first_execute: bool = true ## 是否是第一次执行
