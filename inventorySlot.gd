extends Node2D
class_name InventorySlot

@export var slotMover = 0.0
var currentItem = null
@onready var countText = find_child("CountText", true)

var deltaTimer = 0
@onready var origY = $Mover.position.y
func _process(delta: float) -> void:
	deltaTimer += delta
	$Mover.position.y = origY + sin(deltaTimer + (slotMover/2)) * 1.5

func changeSlot(item, targetInv = Ref.inv):
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
			countText.visible = true
		$Mover/Item.texture = load("res://sprites/"+item+".png")
		$Mover/BG.self_modulate = Color("FFFFFF")
		var c = targetInv[item]["count"]
		if countText != null:
			countText.text = "X" + str(c)
		
		
