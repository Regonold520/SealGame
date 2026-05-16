extends Interactable
class_name Swingable

var breaks = 3
var rng = RandomNumberGenerator.new()

func interact():
	super()
	var newRot
	if rng.randi_range(0,1) == 1:
		newRot = rng.randf_range(-15, -10)
	else:	
		newRot = rng.randf_range(10, 15)
	var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	t.tween_property(self, "rotation_degrees:y", rotation_degrees.y + newRot, 0.3)
	
	breaks -= 1
	if breaks <= 0:
		var ids = ["coal","quartz", "stone", "stone"]
		var prefab = load("res://world_item.tscn")
		for i in randi_range(3,5):
			var newID = ids.pick_random()
			var newItem = prefab.instantiate()
			get_tree().current_scene.add_child(newItem)
			newItem.spawn(global_position, newID)
			await get_tree().create_timer(0.01).timeout
		
		queue_free()
		
		
		
