extends UiButton
class_name ConfirmButton

func press():
	super()
	if Ref.liftManager.openState:
		Ref.liftManager.close()
