extends Node

## 需要通过外部API获取信息时发出
signal need_http_request(url: String)
## 监听以获得http请求返回的数据
signal return_http_get(data: Variant)
