extends Node3D
class_name Item

var moveTween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
@onready var rpv = randi()
var scaleValue = 0.0
var id = null

func spawn(pos, tempID):
	id = tempID
	$Sprite3D.texture = load("res://sprites/" + id + ".png")
	
	var randAngle = randf_range(-PI, PI)
	var nPos = Vector3(cos(randAngle), 0, sin(randAngle))
	var dist = randf_range(0.5, 2)
	
	var finalOffset = dist * nPos
	var dest = pos + finalOffset
	
	var arcPos = pos.lerp(dest, 0.5) + Vector3(0,2,0)
	
	moveTween.tween_method( bezier.bind(pos, arcPos, dest), 0.0 , 1.0 , 0.5 )
	
	var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	t.tween_property(self, "scaleValue", randf_range(0.8, 1.1), 0.5 + randf_range(-0.2, 0.1))

func bezier(time, pos1, pos2, pos3):
	var q0 = pos1.lerp(pos2, time)
	var q1 = pos2.lerp(pos3, time)
	
	global_position = q0.lerp(q1, time)

var deltaTimer = 0
func _process(delta: float) -> void:
	deltaTimer += delta
	$Sprite3D.position.y = 0 + sin(deltaTimer + rpv) / 15
	$Sprite3D.scale = (Vector3(cos(deltaTimer + rpv)/7, sin(deltaTimer + rpv)/7, 0) * 0.5) + Vector3(scaleValue,scaleValue,scaleValue)
	
	var canFlow = true
	if Ref.inv.size() >= 8 and not Ref.inv.has(id):
		canFlow = false
	
	if global_position.distance_to(Ref.seal.chest.global_position) < 1.5 and canFlow:
		if moveTween != null:
			moveTween.kill()
		global_position = global_position.lerp(Ref.seal.chest.global_position, 10.0 * delta)
		if global_position.distance_to(Ref.seal.chest.global_position) < 0.4:
			itemPicked()
			queue_free()
			
func itemPicked():
	print(id)
	Ref.addItem(id)
