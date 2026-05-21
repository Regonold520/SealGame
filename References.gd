extends Node

var blockLookup = {
	"air": 0,
	"stone": 1,
	"glowstone": 2
}

@onready var seal : Seal = get_tree().current_scene.find_child("Seal", true).find_child("CharacterBody3D")
@onready var invManager : InventoryManager = get_tree().current_scene.find_child("ChestCollider", true)
@onready var liftManager : LiftManager = get_tree().current_scene.find_child("LiftManager", true)
@onready var genManager : GenerationManager = get_tree().current_scene.find_child("GenerationManager", true)
@onready var buildManager : BuildManager = get_tree().current_scene.find_child("BuildManager", true)

@onready var invHolder = get_viewport().get_camera_3d().find_child("ExternalInv", true)

var currentBlueprint = null
var inv = {"items": {}, "id": "player"}
var buildMode = true

var allInvs = []

var buildRef

func _ready() -> void:
	buildRef = parse_json_path("res://datastore/buildables.json")
	inv["obj"] = self
	allInvs.append(inv)
	await get_tree().create_timer(1).timeout

func parse_json_path(path):
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var json_text := file.get_as_text()
		file.close()
		var result = JSON.parse_string(json_text)
		if result != null:
			var my_dict : Dictionary = result
			return my_dict
		else:
			push_error("Failed to parse JSON")

func addItem(id, count = 1):
	var has = false
	if inv["items"].get(id):
		inv["items"][id]["count"] += count
		
		for i in inv["items"].keys():
			if i == null: inv["items"].erase(i)
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
		
		for i in inv["items"].keys():
			if i == null: inv["items"].erase(i)
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
