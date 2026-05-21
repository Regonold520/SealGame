extends UiButton
class_name BlueprintConfirmButton

func press():
	super()
	if Ref.currentBlueprint != null:
		Ref.currentBlueprint.close()
		Ref.currentBlueprint.visible = false
		Ref.currentBlueprint.canInteract = true
		Ref.currentBlueprint.find_child("CollisionShape3D").disabled = true
		Ref.buildManager.buildBuilding(Ref.currentBlueprint.blueprintID, Ref.currentBlueprint.global_position)
		await Ref.currentBlueprint.moveTween.finished
		print("HERIOA")
		Ref.currentBlueprint.queue_free()
