extends Interactable
class_name StorageContainer

var inventory = {}
var slots = []
@export var slotCount = 4
@export var drawColumns = 2
@export var drawRows = 2

func _ready() -> void:
	var slotScene = load("res://slot.tscn")
	for i in slotCount:
		var newSlot = slotScene.instantiate()
		slots.append(newSlot)

func addItem(id, count = 1):
	var has = false
	if inventory.get(id):
		inventory[id]["count"] += count
	else:
		var newEntry = {
			"count": count
		}
		inventory[id] = newEntry
	var c = 0

	for item_id in inventory.keys():
		slots[c].changeSlot(item_id, inventory)
		c += 1

func drawInv():
	var c = 0
	var spacerX = 25
	var spacerY = 22
	
	for i in Ref.invHolder.get_children():
		i.queue_free()
		
	var currSlot = 0
	for y in drawRows:
		for x in drawColumns:
			if slots.size() > currSlot:
				slots[currSlot].slotMover = float(y)
				var d = slots[currSlot].duplicate()
				d.changeSlot(slots[currSlot].currentItem, inventory)
				Ref.invHolder.add_child(d)
				d.position = Vector2((0 + x*spacerX) - ((drawColumns-1)*spacerX)/2,
					(0 + y * spacerY) - ((drawRows-1)*spacerY)/2)
			currSlot += 1
