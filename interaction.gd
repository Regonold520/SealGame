extends Node3D

var ray = RayCast3D.new()
@onready var tree = get_parent().find_child("AnimationTree", true)
var cooldown = 0.4
var swinging = false

func _ready() -> void:
	add_child(ray)

func _process(delta: float) -> void:
	var mousePos : Vector2 = get_viewport().get_mouse_position()
	var cam : Camera3D = get_viewport().get_camera_3d()
	
	var origin = cam.project_ray_origin(mousePos)
	var normal = cam.project_ray_normal(mousePos)
	
	ray.global_position = origin
	ray.target_position = origin + normal*5000
	ray.collision_mask = 3
	
	if Ref.buildMode:
		var hitPos = ray.get_collision_point()
		var tilePos = Ref.genManager.global_to_tile(hitPos)
		var acPos = Ref.genManager.get_global_tile_pos(
			tilePos["chunkX"], tilePos["chunkY"],
			tilePos["tileX"], tilePos["tileY"]-64, tilePos["tileZ"]
		)
		if Ref.buildManager.currentDisplay != null:
			Ref.buildManager.changeDisplayPos(acPos + Vector3(0.5,0,0.5))
			Ref.buildManager.displayBlockPos = tilePos
	else:
		if Input.is_action_just_pressed("Interact"):
			clicked()
		
		
				
			
			
func clicked():
	if ray.get_collider():
		var obj = ray.get_collider()
		if obj.global_position.distance_to(Ref.seal.global_position) <= 3.0:
			if obj is Swingable and swinging == false:
				
				swinging = true
				tree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
				
				await get_tree().create_timer(0.3).timeout
				obj.interact()
				
				await get_tree().create_timer(cooldown).timeout
				swinging = false
			elif obj is Interactable and obj is not Swingable:
				obj.interact()
