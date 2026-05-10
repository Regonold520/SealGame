extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	var direction = ($"..".find_child("CamAxis", true).transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	print(direction)
	if direction:
		$Model.rotation.y = atan2(-direction.x, -direction.z)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	var cam_axis = $"..".find_child("CamAxis")
	
	cam_axis.rotation.y = lerp_angle(
		cam_axis.rotation.y,
		target_rotation,
		delta * 15.0
	)
	
	cam_axis.position = cam_axis.position.lerp(position, delta * 7.0)

var dragging = false
var drag_start_x = 0.0

var target_rotation = 0.0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			
			if dragging:
				drag_start_x = event.position.x

	elif event is InputEventMouseMotion and dragging:
		target_rotation -= event.relative.x * 0.01
		
