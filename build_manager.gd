extends Node3D
class_name BuildManager

var currentDisplay : StaticBody3D = null
var currentID = null
var displayBlockPos = null
var newMat = null
var validPlacement = true
var oldPos = null
var overAnother = false

var placedBlueprints = [] 

func _ready() -> void:
	select("crate")

func select(id):
	currentID = id
	if id == "":
		if currentDisplay != null:
			currentDisplay.queue_free()
	else:
		var model = load("res://buildables/" + id + ".gltf").instantiate()
		var newBuilding = load("res://blueprint.tscn")
		currentDisplay  = newBuilding.instantiate()
		currentDisplay.find_child("CollisionShape3D").disabled = true
		currentDisplay.find_child("Model").add_child(model)
		
		newMat = StandardMaterial3D.new()
		newMat.albedo_color = Color("0078fd89")
		newMat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		newMat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_OPAQUE_ONLY
		
		var kids = currentDisplay.find_children("*", "MeshInstance3D", true, false)
		for i in kids:
			if i is MeshInstance3D:
				i.material_override = newMat
		add_child(currentDisplay)
		if oldPos != null:
			currentDisplay.global_position = oldPos

func _process(delta: float) -> void:
	if currentDisplay != null:
		var belowBlockID = Ref.genManager.getBlock(
				displayBlockPos["chunkX"], displayBlockPos["chunkY"],
				displayBlockPos["tileX"], displayBlockPos["tileY"]-1, displayBlockPos["tileZ"]
			)
		
		var selfBlockID = Ref.genManager.getBlock(
				displayBlockPos["chunkX"], displayBlockPos["chunkY"],
				displayBlockPos["tileX"], displayBlockPos["tileY"], displayBlockPos["tileZ"]
			)
		if belowBlockID == 0 or selfBlockID != 0:
			validPlacement = false
			
		else:
			var tag = true

			for i in placedBlueprints:
				if i["pos"] == Vector3(
					displayBlockPos["chunkX"] * 16 + displayBlockPos["tileX"],
					displayBlockPos["tileY"],
					displayBlockPos["chunkY"] * 16 + displayBlockPos["tileZ"]
				):
					tag = false
					break
			overAnother = !tag
			validPlacement = tag
			
		
		if Input.is_action_just_pressed("Interact"):
			if validPlacement:
				currentDisplay.find_child("CollisionShape3D").disabled = false
				moveTween.kill()
				currentDisplay.global_position = oldPos
				var newEntry = {
					"obj": currentDisplay,
					"id": currentID,
					"pos": Vector3(
						displayBlockPos["chunkX"] * 16 + displayBlockPos["tileX"],
						displayBlockPos["tileY"],
						displayBlockPos["chunkY"] * 16 + displayBlockPos["tileZ"]
					)
				}
				
				placedBlueprints.append(newEntry)
				newMat.albedo_color = Color("0078fd89")
				currentDisplay = null
				
				select(currentID)
			if overAnother:
				for i in placedBlueprints:
					if i["pos"] == Vector3(
						displayBlockPos["chunkX"] * 16 + displayBlockPos["tileX"],
						displayBlockPos["tileY"],
						displayBlockPos["chunkY"] * 16 + displayBlockPos["tileZ"]
					):
						print("erio", i)
						i["obj"].queue_free()
						placedBlueprints.erase(i)
		
	if newMat != null:
		if validPlacement:
			newMat.albedo_color = Color("0078fd89")
		else:
			newMat.albedo_color = Color("fd000089")
	
	if Input.is_action_just_pressed("Build"):
		Ref.buildMode = !Ref.buildMode 
		
		
		
		if Ref.buildMode == false:
			select("")
		else:
			select("crate")

var lastPos = null
var moveTween = null
func changeDisplayPos(pos):
	if lastPos == null:
		lastPos = pos
	
	if lastPos != pos:
		if moveTween != null:
			moveTween.kill()
		moveTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		moveTween.tween_property(currentDisplay, "global_position", pos, 0.1)
		oldPos = pos
	
	lastPos = pos

func buildBuilding(id, pos):
	var scene = load("res://buildables/"+id+".tscn").instantiate()
	add_child(scene)
	scene.global_position = pos
