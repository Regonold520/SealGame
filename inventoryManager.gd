extends Interactable
class_name InventoryManager

var open = false

@onready var tween
@onready var uiHolder = get_viewport().get_camera_3d().find_child("CanvasLayer")

signal slotclicked

var slots = []
func _ready() -> void:
	slotclicked.connect(slotClicked)
	var holder = get_viewport().get_camera_3d().find_child("Items", true)
	slots = holder.get_children()

func interact():
	if Ref.seal.canInv:
		open = !open
		if open:
			openInv()
		else:
			closeInv()
			
func openInv(ji = false):
	if tween != null:
		tween.kill()
	tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	if ji == false:
		tween.tween_property(get_viewport().get_camera_3d(), "fov", 50.0, 0.6)
		
		tween.tween_property(uiHolder.find_child("ScreenColour"), "color", Color("00000046"), 0.8)
		var seal_model = Ref.seal.find_child("SealModel")
		var cam = get_viewport().get_camera_3d()

		var dir = cam.global_position - seal_model.global_position
		var rot = atan2(dir.x, dir.z)

		tween.tween_property(seal_model, "rotation:y", rot + PI, 0.6)
	
	tween.tween_property(uiHolder.find_child("ItemsPanel"), "position:x", 349.0, 0.6)
	
	

func closeInv(ji = false):
	if tween != null:
		tween.kill()
	tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	if ji == false:
		tween.tween_property(get_viewport().get_camera_3d(), "fov", 75.0, 0.6)
		
		tween.tween_property(uiHolder.find_child("ScreenColour"), "color", Color("00000000"), 0.6)
		
	
	tween.tween_property(uiHolder.find_child("ItemsPanel"), "position:x", -171.0, 0.3)

func slotClicked(slot, inv):
	pass
