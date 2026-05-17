extends UiButton
class_name ExitButton

func press():
	super()
	if Ref.liftManager.openState:
		Ref.liftManager.close()
