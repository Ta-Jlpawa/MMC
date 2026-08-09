extends RefCounted
## 文件操作类，封装一些文件操作用逻辑，文件复制相关应当使用 FileCopier.
class_name FileOperator


## 将文件移动到回收站
static func remove_files(file_path: PackedStringArray):
	for i in file_path:
		OS.move_to_trash(i)
	print("INFO: [FileRemover] 移除 %s 个文件" % [file_path.size()])


## 将文件永久删除
static func delete_files(file_path: PackedStringArray):
	for i in file_path:
		DirAccess.remove_absolute(i)
	print("INFO: [FileRemover] 永久移除 %s 个文件" % [file_path.size()])


## 获取列表中所有文件的文件名(含后缀)
static func get_file_name(file_path: PackedStringArray) -> PackedStringArray:
	var file_name: PackedStringArray = []
	for i in file_path:
		file_name.append(i.get_file())
	return file_name
