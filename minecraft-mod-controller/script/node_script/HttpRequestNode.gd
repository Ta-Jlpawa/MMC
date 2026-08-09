extends Node
class_name HttpRequestNode

var http_request: HTTPRequest = null


func _ready() -> void:
	http_request = HTTPRequest.new()
	self.add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	EventBus.need_http_request.connect(emit_get_request)
	
	#emit_get_request("https://staging-api.modrinth.com/")
	#emit_get_request("https://api.modrinth.com/v2/project/appleskin")


## 向指定URL发送GET请求
func emit_get_request(url: String) -> Error:
	var err: Error = http_request.request(url)
	match err: # TODO: 错误检测机制
		_:
			pass
	return err
	

## 当请求完成时触发
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
