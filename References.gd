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

var inv = {}

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	addItem("quartz", 99)

func addItem(id, count = 1):
	var has = false
	if inv.get(id):
		inv[id]["count"] += count
	else:
		var newEntry = {
			"count": count
		}
		inv[id] = newEntry
	var c = 0

	for item_id in inv.keys():
		invManager.slots[c].changeSlot(item_id)
		c += 1
