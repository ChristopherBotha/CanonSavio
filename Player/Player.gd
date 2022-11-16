extends CharacterBody3D


var SPEED = 5.0
var JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var maxSpeed : float = 10.0
var minSpeed : float = 0.0
var maxJumpHeight : float = 6

var momentum : float = 0.1
var friction : float = 0.05
var airFriction : float = 0.07

@onready var body = $CollisionShape3D
var h_rot

func _physics_process(delta):
	
	
	# Add the gravity.
	velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		while velocity.y < maxJumpHeight:
			velocity.y += JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	sprinting(delta)
	move_and_slide()

func handleInput(delta):
	
	h_rot = $Camera_Orbit/h.global_transform.basis.get_euler().y
	
	var input_dir = Vector3(Input.get_action_strength("right") - Input.get_action_strength("left"),0,
				Input.get_action_strength("down") - Input.get_action_strength("up")).rotated(Vector3.UP, h_rot).normalized()
				
#	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if input_dir.z != 0 or input_dir.x != 0:
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
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func sprinting(delta):
	if Input.is_action_pressed("sprint"):
		SPEED = maxSpeed
		handleInput(delta)
	else:
		SPEED = 5.0
		handleInput(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
