extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var maxSpeed : float = 10.0
var minSpeed : float = 0.0
var maxJumpHeight = 6

var momentum : float = 0.1
var friction : float = 0.05
var airFriction : float = 0.07

func _physics_process(delta):
	# Add the gravity.
	velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		while velocity.y < maxJumpHeight:
			velocity.y += JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	handleInput(delta)
	move_and_slide()

func handleInput(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and !is_on_floor():
		velocity = velocity.lerp(Vector3(direction.x * SPEED, velocity.y, direction.z * SPEED), airFriction ) 
		
	elif !is_on_floor():
		velocity.z = move_toward(velocity.z, 0, airFriction)
		velocity.x = move_toward(velocity.x, 0, airFriction)
		
	elif direction and is_on_floor():
		velocity = velocity.lerp(Vector3(direction.x,0.0,direction.z) * SPEED, momentum ) 
		
	elif is_on_floor() and direction == Vector3.ZERO:
		velocity = velocity.lerp(Vector3(0.0, velocity.y, 0.0), friction ) 
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
