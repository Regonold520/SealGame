extends Area2D
class_name UiButton

var hovering = false
@onready var texture : Sprite2D = find_child("Texture")
@onready var rpv = randi()

var deltaTimer = 0
func _process(delta: float) -> void:
	deltaTimer += delta
	texture.position.y = 0 + sin((deltaTimer + rpv) * 2)
	
	texture.rotation_degrees = 0 + (cos((deltaTimer + rpv) * 10) * 5 * int(hovering))
	
	if hovering and Input.is_action_just_pressed("Interact"):
		press()

func _mouse_enter() -> void:
	hovering = true

func _mouse_exit() -> void:
	hovering = false

func press():
	pass
