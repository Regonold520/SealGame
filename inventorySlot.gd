extends Area2D
class_name InventorySlot

@export var slotMover = 0.0
var currentItem = null
@onready var countText = find_child("CountText", true)
var hovering = false
var myInv = null
var deltaTimer = 0
@onready var origY = $Mover.position.y
var displayCount = true

var lunkSlot = null

func _process(delta: float) -> void:
	deltaTimer += delta
	$Mover.position.y = origY + sin(deltaTimer + (slotMover/2)) * 1.5
	if hovering and Input.is_action_just_pressed("Interact"):
		
		Ref.invManager.slotclicked.emit(self, myInv)

func changeSlot(item, targetInv = Ref.inv):
	myInv = targetInv
	currentItem = item
	countText = find_child("CountText", true)
	if item == null:
		if countText != null:
			countText.visible = false
			countText.text = ""
		$Mover/Item.texture = null
		$Mover/BG.self_modulate = Color("979797")
	else:
		if countText != null:
			if displayCount == true:
				countText.visible = true
		$Mover/Item.texture = load("res://sprites/"+item+".png")
		$Mover/BG.self_modulate = Color("FFFFFF")
		
		if targetInv["items"].get(item) == null:
			targetInv["items"][item] = {"count": 0}
		
		
		var c = targetInv["items"][item]["count"]
		if countText != null and displayCount == true:
			countText.text = "X" + str(c)
		
func _mouse_enter() -> void:
	hovering = true

func _mouse_exit() -> void:
	hovering = false
