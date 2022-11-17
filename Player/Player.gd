extends CharacterBody3D
class_name Player

var SPEED = 5.0
var JUMP_VELOCITY = 4.5
var dashSpeed = 200


var dashing = false
#	set(new_value): 
#		dashing = new_value
#	get:
#		return dashing
	
var sprinting : bool = false
var jumping : bool = false
var attacking : bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var health: float = 100:
	set(new_value): 
		health = clamp(new_value,0,100)
		SignalBus.emit_signal("healthUpdated", health)
		
var maxSpeed : float = 15
var minSpeed : float = 0.0
var maxJumpHeight : float = 6
var dir = Vector3.ZERO
var momentum : float = 0.1
var friction : float = 0.05
var airFriction : float = 0.07

@onready var state_name = $State_Machine
@onready var body = $Body
@onready var back = $Body/Back
@onready var camera = $Camera_Orbit/h/v/SpringArm3D/Camera3D
@onready var cams = $Camera_Orbit
@onready var hand = $Body/hand

var h_rot

func _physics_process(delta):
	# Add the gravity.
	
	if !is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	sprintFalse()
	handleInput(delta)
	handle_animaton()
	move_and_slide()

func handleInput(delta):
	
	h_rot = $Camera_Orbit/h.global_transform.basis.get_euler().y
	
	var input_dir = Vector3(Input.get_action_strength("right") - Input.get_action_strength("left"),0,
				Input.get_action_strength("down") - Input.get_action_strength("up")).rotated(Vector3.UP, h_rot).normalized()

	dir = input_dir
	
	#rotate body accroding to mouse input
	if input_dir.z != 0 or input_dir.x != 0 :
		body.rotation.y = lerp_angle(body.rotation.y, atan2(input_dir.x, input_dir.z), delta * 5)
	
	
	if input_dir and !is_on_floor():
		velocity = velocity.lerp(Vector3(input_dir.x * SPEED, velocity.y, input_dir.z * SPEED), airFriction ) 
	elif !is_on_floor():
		velocity.z = move_toward(velocity.z, 0, airFriction)
		velocity.x = move_toward(velocity.x, 0, airFriction)
		
	elif input_dir and is_on_floor():
		velocity = velocity.lerp(Vector3(input_dir.x,0.0,input_dir.z) * SPEED, momentum ) 
		
	elif is_on_floor() and input_dir == Vector3.ZERO:
		velocity = velocity.lerp(Vector3(0.0, velocity.y, 0.0), friction ) 
		velocity.y = 0.0

	else:
		velocity = velocity.lerp(Vector3(input_dir.x,0.0,input_dir.z) * SPEED, momentum ) 
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#		velocity.z = move_toward(velocity.z, 0, SPEED)

func sprint():
	if Input.is_action_pressed("sprint"):
		SPEED = maxSpeed
		camera.near = move_toward(camera.near, 0.5, 0.02)
	elif Input.is_action_just_released("sprint"):
		sprinting = false

func sprintFalse():
	if sprinting == false:
		SPEED = 5.0
		camera.near = move_toward(camera.near, 0.8, 0.02)

func dash():
	if dashing == true and is_on_floor():
		SignalBus.emit_signal("delayChange")
		
		var where = $Body/RayCast3D.get_collision_point()
		if dir != Vector3.ZERO:
			velocity = velocity.direction_to(Vector3(where.x, 0.0, where.z)) * dashSpeed
			velocity = velocity.lerp(Vector3.ZERO, 0.2 ) 
		elif dir == Vector3.ZERO:
			velocity = velocity.direction_to(Vector3(where.x, 0.0, where.z)) * dashSpeed 
			velocity = velocity.lerp(Vector3.ZERO, 1.3 ) 
		velocity = velocity.move_toward(Vector3.ZERO, 0.2 )

		await get_tree().create_timer(1).timeout
		dashing = false
		
	else: 
		SPEED = 5.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_hand_body_entered(body):
	if body.is_in_group("Enemies"):
		SignalBus.emit_signal("releaseVictim",null)

func handle_animaton():
	for j in state_name.get_children():
		if state_name.state.name == j.get_name():
			pass
