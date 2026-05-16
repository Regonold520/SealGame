extends Node2D
class_name InventorySlot

@export var slotMover = 0.0
var currentItem = null
@onready var countText = find_child("CountText", true)

var deltaTimer = 0
@onready var origY = position.y
func _process(delta: float) -> void:
	deltaTimer += delta
	position.y = origY + sin(deltaTimer + (slotMover/2)) * 1.5

func changeSlot(item):
	if item == null:
		countText.visible = false
		countText.text = ""
		$Item.texture = null
		$BG.self_modulate = Color("979797")
	else:
		countText.visible = true
		$Item.texture = load("res://sprites/"+item+".png")
		$BG.self_modulate = Color("FFFFFF")
		var c = Ref.inv[item]["count"]
		countText.text = "X" + str(c)
		
		
