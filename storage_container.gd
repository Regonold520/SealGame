extends Interactable
class_name StorageContainer

var inventory = {"items": {}}
var slots = []
@export var slotCount = 4
@export var drawColumns = 2
@export var drawRows = 2

@export var invId = "basic"
var linkedInv = null


signal slotclicked

func _ready() -> void:
	inventory["id"] = invId
	inventory["obj"] = self
	Ref.allInvs.append(inventory)
	slotclicked.connect(slotClicked)
	var slotScene = load("res://slot.tscn")
	for i in slotCount:
		var newSlot = slotScene.instantiate()
		slots.append(newSlot)


func addItem(id, count = 1):
	var has = false
	if inventory["items"].get(id):
		inventory["items"][id]["count"] += count
	else:
		var newEntry = {
			"count": count
		}
		inventory["items"][id] = newEntry
	refreshSlots()

func removeItem(id, count = 1):
	var has = false
	if inventory["items"].get(id):
		inventory["items"][id]["count"] -= count
		
		if inventory["items"][id]["count"] <= 0:
			inventory["items"].erase(id)
	else:
		pass

	refreshSlots()

func drawInv():
	var spacerX = 25
	var spacerY = 22
	for i in Ref.invHolder.get_children():
		i.queue_free()
	linkedInv = []
	for i in slots:
		linkedInv.append(i.duplicate())
	var currSlot = 0
	for y in drawRows:
		for x in drawColumns:
			if linkedInv.size() > currSlot:
				var d = linkedInv[currSlot]
				d.slotMover = float(y)
				d.changeSlot(slots[currSlot].currentItem, inventory)
				Ref.invHolder.add_child(d)
				d.position = Vector2(
					(x * spacerX) - ((drawColumns - 1) * spacerX) / 2,
					(y * spacerY) - ((drawRows - 1) * spacerY) / 2
				)
			currSlot += 1

func clearInv():
	
	for i in linkedInv:
		i.queue_free()
	linkedInv = null

func slotClicked(slot, inv):
	pass

func refreshSlots():
	for slot in slots:
		slot.changeSlot(null)

	if linkedInv != null:
		for slot in linkedInv:
			slot.changeSlot(null)

	var c = 0

	for item_id in inventory["items"].keys():
		slots[c].changeSlot(item_id, inventory)

		if linkedInv != null and linkedInv.size() > c:
			linkedInv[c].changeSlot(item_id, inventory)

		c += 1
