extends Control
## 信息显示组件基类，拥有三种状态
class_name InformationUIObject


## 组件状态
enum State{
	NORMAL, ## 普通状态
	CHOICE, ## 选中状态，代表该组件被选中
}
