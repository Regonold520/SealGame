extends StorageContainer
class_name LiftManager

var openState = false
@onready var animPlayer : AnimationPlayer = find_child("AnimationPlayer", true)
@onready var moveTween = create_tween()

func interact():
	if animPlayer.is_playing() == false and openState == false and Ref.seal.canInv:
		openState = !openState
		if openState:
			open()

var origPos = Vector3.ZERO
var origRot = 0
@onready var camAxis = get_viewport().get_camera_3d().get_parent().get_parent()

@onready var menu = get_viewport().get_camera_3d().find_child("TopMenu", true)
@onready var invDisplay = get_viewport().get_camera_3d().find_child("ExternalInv", true)

func _ready() -> void:
	Ref.invManager.slotclicked.connect(slotClicked)
	super()

func slotClicked(slot : InventorySlot, inv):
	if openState:
		if inv != null:
			if inv["id"] == "player":
				Ref.getInv("lift")["obj"].addItem(slot.currentItem)
				Ref.getInv("player")["obj"].removeItem(slot.currentItem)
			elif inv["id"] == "lift":
				Ref.getInv("player")["obj"].addItem(slot.currentItem)
				Ref.getInv("lift")["obj"].removeItem(slot.currentItem)

var deltaTimer = 0
func _process(delta: float) -> void:
	deltaTimer += delta

func open():
	
	animPlayer.play("open")
	Ref.seal.camOverwrite = true
	Ref.seal.canMove = false
	moveTween.kill()
	moveTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_parallel()
	var cam = get_viewport().get_camera_3d()
	cam.reparent(get_tree().current_scene)
	origPos = cam.global_position
	origRot = cam.rotation_degrees
	moveTween.tween_property(cam, "global_position", $CamPoint.global_position, 0.6)
	moveTween.tween_property(invDisplay, "position:x", 869.0, 0.6)
	var start_rot = cam.rotation
	var target_rot = $CamPoint.global_rotation
	Ref.invManager.openInv(true)
	moveTween.tween_method(
		func(weight):
			cam.rotation.x = lerp_angle(start_rot.x, target_rot.x, weight)
			cam.rotation.y = lerp_angle(start_rot.y, target_rot.y, weight)
			cam.rotation.z = lerp_angle(start_rot.z, target_rot.z, weight),
		0.0,
		1.0,
		0.6
	)
	moveTween.tween_property(menu, "position:y", 0, 0.6)
	drawInv()

func close():
	animPlayer.play("close")
	openState = false
	
	Ref.invManager.closeInv(true)
	moveTween.kill()
	moveTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_parallel()
	var cam = get_viewport().get_camera_3d()
	cam.reparent(camAxis)
	moveTween.tween_property(cam, "position", Vector3(0, 0.965, 3.453), 0.6)
	moveTween.tween_property(cam, "rotation_degrees", Vector3(-19.2, 0, 0), 0.6)
	moveTween.tween_property(menu, "position:y", -148.0, 0.6)
	moveTween.tween_property(invDisplay, "position:x", 1331.0, 0.6)
	Ref.seal.camOverwrite = false
	Ref.seal.canMove = true
	await moveTween.finished
	clearInv()
