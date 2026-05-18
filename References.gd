extends Node

var blockLookup = {
	"air": 0,
	"stone": 1,
	"glowstone": 2
}

@onready var seal : Seal = get_tree().current_scene.find_child("Seal", true).find_child("CharacterBody3D")
@onready var invManager : InventoryManager = get_tree().current_scene.find_child("ChestCollider", true)
@onready var liftManager : LiftManager = get_tree().current_scene.find_child("LiftManager", true)

@onready var invHolder = get_viewport().get_camera_3d().find_child("ExternalInv", true)

var inv = {"items": {}, "id": "player"}

var allInvs = []

func _ready() -> void:
	inv["obj"] = self
	allInvs.append(inv)
	await get_tree().create_timer(1).timeout

func addItem(id, count = 1):
	var has = false
	if inv["items"].get(id):
		inv["items"][id]["count"] += count
	else:
		var newEntry = {
			"count": count
		}
		inv["items"][id] = newEntry
	refreshSlots()

func removeItem(id, count = 1):
	var has = false
	if inv["items"].get(id):
		inv["items"][id]["count"] -= count
		
		if inv["items"][id]["count"] <= 0:
			inv["items"].erase(id)
	else:
		pass
	refreshSlots()
	
	
	
func getInv(toGet) -> Dictionary:
	for i in allInvs:
		if i["id"] == toGet:
			return i
	return {}

func refreshSlots():
	for slot in invManager.slots:
		slot.changeSlot(null)

	var c = 0
	for item_id in inv["items"].keys():
		invManager.slots[c].changeSlot(item_id, inv)

		c += 1
