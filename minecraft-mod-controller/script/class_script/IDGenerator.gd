extends RefCounted
## 随机ID生成器
class_name IDGenerator

const CHARACTERS := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"


## 为模组配置生成一个长度为8的随机ID
static func generate_modcfg_id(length: int = 8) -> String:
	var id: String = ""
	var rng: RandomNumberGenerator= RandomNumberGenerator.new()
	rng.randomize()
	while true:
		for i in range(length):
			id += CHARACTERS[rng.randi_range(0, CHARACTERS.length() - 1)]
		if id not in GameManager.modcfg_data: break
		else: print("WTF: [IDGenerator] ID生成重复?!你的运气真好！")
			
	print("INFO: [IDGenerator] 生成ID %s" % id)
	return id
