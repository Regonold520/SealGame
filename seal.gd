extends CharacterBody3D
class_name Seal

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var current_speed := 0.0

var camOverwrite = false
var canMove = true

@export var chest : Marker3D

func _ready() -> void:
	var pick = load("res://models/pick/pick.gltf").instantiate()
	find_child("hand", true).add_child(pick)

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
	if direction and !Ref.invManager.open and canMove:
		$SealModel.rotation.y = lerp_angle(
			$SealModel.rotation.y,
			atan2(-direction.x, -direction.z),
			delta * 15.0
		)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	var target_speed = input_dir.length()
	current_speed = lerp(current_speed, target_speed, delta * 10)
	
	if Ref.invManager.open:
		current_speed = 0
	
	$SealModel/AnimationTree.set("parameters/BlendSpace1D/blend_position", current_speed)
	move_and_slide()
	var cam_axis = $"..".find_child("CamAxis")
	if camOverwrite == false: 
		cam_axis.rotation.y = lerp_angle(
			cam_axis.rotation.y,
			target_rotation.x,
			delta * 25.0
		)
		
		cam_axis.rotation.x = lerp_angle(
			cam_axis.rotation.x,
			target_rotation.y,
			delta * 25.0
		)
		
		
		
		cam_axis.position = cam_axis.position.lerp(position, delta * 20.0)

var dragging = false
var drag_start_x = 0.0

var target_rotation = Vector2()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			
			if dragging:
				drag_start_x = event.position.x

	elif event is InputEventMouseMotion and dragging:
		if camOverwrite == false:
			target_rotation.x -= event.relative.x * 0.01
			target_rotation.y -= event.relative.y * 0.01
		
@onready var shakeTween = create_tween()
func camShake(intensity):
	var rotator = get_viewport().get_camera_3d().get_parent()
	if shakeTween != null:
		shakeTween.kill()
	shakeTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	var cRot = 0
	if randi_range(0,1) == 1:
		cRot = randf_range(intensity - (intensity/2), intensity + (intensity/2))
	else:
		cRot = randf_range(-intensity - (intensity/2), -intensity + (intensity/2))
	
	rotator.rotation_degrees.z = cRot
	shakeTween.tween_property(rotator, "rotation_degrees:z", 0, 1)
	
