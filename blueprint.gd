extends StorageContainer
class_name Blueprint

var requirements
var openState = false
var canConstruct = false
var canInteract = true
var blueprintID = "crate"

@onready var invDisplay = get_viewport().get_camera_3d().find_child("ExternalInv", true)
@onready var confirmDisplay = get_viewport().get_camera_3d().find_child("BlueprintPanel", true)

func _ready() -> void:
	requirements = Ref.buildRef[blueprintID]["requirements"]
	
	for i in requirements:
		requirements[i] = int(requirements[i])
	
	displayCount = false
	Ref.invManager.slotclicked.connect(slotClicked)
	slotCount = requirements.size()
	drawColumns = 1
	drawRows = requirements.size()
	
	super()
	
	var c = 0
	for i in slots:
		var keys = requirements.keys()
		i.displayCount = false
		#i.find_child("CountText").visible = false
		i.changeSlot(keys[c], inventory)
		c += 1

func _process(delta: float) -> void:
	if openState:     
		confirmDisplay.visible = canConstruct

func slotClicked(slot : InventorySlot, inv):
	if openState:
		if inv != null:
			if inv["id"] == "player":
				if slot.currentItem in requirements.keys():
					if inventory["items"][slot.currentItem]["count"] < requirements[slot.currentItem]:
						var keys = requirements.keys()
						var index = keys.find(slot.currentItem)
						addItem(slot.currentItem)
						
						#slots[index]
						slots[index].lunkSlot.find_child("CountText2").text = str(inventory["items"][slot.currentItem]["count"]) + "/" + str(requirements[slot.currentItem]) + "\n" + slot.currentItem
						Ref.getInv("player")["obj"].removeItem(slot.currentItem)
						refreshSlots()
					var f = false
					for i in slots:
						if inventory["items"][i.currentItem]["count"] < requirements[i.currentItem]:
							f = true
					if f == false:
						canConstruct = true

func interact():
	if !Ref.buildMode and canInteract and !Ref.invManager.open:
		openState = !openState
		
		if openState:
			Ref.currentBlueprint = self
			open()
		else:
			Ref.currentBlueprint = null
			close()
		
var moveTween =  create_tween()
func open():
	Ref.seal.canInv = false
	Ref.invManager.openInv(false)
	drawInv()
	Ref.seal.canMove = false
	
	moveTween.kill()
	moveTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_parallel()
	moveTween.tween_property(confirmDisplay, "position:x", 932.0, 0.6)
	moveTween.tween_property(invDisplay, "position:x", 869.0, 0.6)

func close():
	Ref.seal.canInv = true
	Ref.invManager.closeInv(false)
	
	moveTween.kill()
	moveTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_parallel()
	moveTween.tween_property(confirmDisplay, "position:x", 1331.0, 0.6)
	moveTween.tween_property(invDisplay, "position:x", 1286.0, 0.6)
	
	Ref.seal.canMove = true
	
	await moveTween.finished
	clearInv()

func refreshSlots():
	super()
	
	for i in slots:
		i.lunkSlot.find_child("CountText2").text = str(inventory["items"][i.currentItem]["count"]) + "/" + str(requirements[i.currentItem]) + "\n" + i.currentItem
