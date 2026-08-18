extends PanelContainer


func state_toggled(state: InformationUIObject.State):
	if state == InformationUIObject.State.NORMAL:
		self_modulate = Color(1, 1, 1)
	else:
		self_modulate = Color(1.0, 0.443, 1.0, 1.0)
		
