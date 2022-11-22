extends CharacterBody3D
class_name Player

@onready var bullet = preload("res://weapons/bullet_body.tscn")
@onready var nozzle = $Body/nozzle

var direction # direction which player is facing

var myEquip = { 
	0: "sword",
	1: "gun"
}
var shot = false

var guns = {
	"machineGun": machineGun(),
	"magNum": magNum(),
	"shotGun": shotGun()
}


var SPEED = 5.0
var JUMP_VELOCITY = 4.5
var dashSpeed = 200
@onready var eyes = $eyes
@onready var playback = $AnimationTree.get("parameters/playback")
var dashing = false
var sprinting : bool = false
var jumping : bool = false
var attacking : bool = false
@onready var shootCast = $Camera_Orbit/h/v/SpringArm3D/Camera3D/RayCast3D2
@onready var aimCast = $Body/RayCast3D

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
@onready var horRot = $Camera_Orbit/h

var h_rot

func _physics_process(delta):
	if !is_on_floor():
		velocity.y -= gravity * delta
		
	pushBack()
	
	shoot()
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
		body.rotation.y = lerp_angle(body.rotation.y, atan2(input_dir.x, input_dir.z), delta * 10)
	
	
	if input_dir and !is_on_floor():
		velocity = velocity.lerp(Vector3(input_dir.x * SPEED, velocity.y, input_dir.z * SPEED), airFriction ) 
		
	elif !is_on_floor() :
		velocity = velocity.lerp(Vector3(input_dir.x * SPEED, velocity.y, input_dir.z * SPEED), airFriction ) 
		
	elif input_dir and is_on_floor():
		velocity = velocity.lerp(Vector3(input_dir.x,0.0,input_dir.z) * SPEED, momentum ) 
		
	elif is_on_floor() and input_dir == Vector3.ZERO:
		velocity = velocity.lerp(Vector3(0.0, velocity.y, 0.0), friction ) 

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
			velocity = velocity.direction_to(Vector3(where.x, 0.0, where.z)) * (dashSpeed - 20)
			velocity = velocity.lerp(Vector3.ZERO, 1.3) 
			
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
			playback.travel(state_name.state.name)

func hurt(damage)-> void:
	health -= damage

func _on_hit_box_body_entered(body):
	if body.is_in_group("Enemies"):
		if body.has_method("hurt"):
			body.hurt(50, -5, 0.1,0.1)
	pass # Replace with function body.

func attackingFalse()-> void:
	attacking = false

func machineGun()-> void:
	pass

func magNum() -> void:
	if shot == true and aimCast.get_collider() != null and is_on_floor():
		var DAMAGE = 50
		
		var bullets = bullet.instantiate()
		nozzle.add_child(bullets)
		bullets.look_at(aimCast.get_collision_point(), Vector3.UP)
		
		if aimCast.get_collider().is_in_group("Enemies"):
			print(aimCast.get_collider())
			if aimCast.get_collider().has_method("hurt"):
				aimCast.get_collider().hurt(DAMAGE, -1, 0.1,0.01)

func shotGun()-> void:
	pass
	
func shoot() -> void:

	if Input.is_action_just_pressed("shoot") and shot == false:
		shot = true
		magNum()
		await get_tree().create_timer(0.1).timeout
		shot = false
		pass

func pushBack():
	if aimCast.get_collider() != null:
		var dir_x = (aimCast.get_collider().global_position.x - global_transform.origin.x)
		var dir_z = (aimCast.get_collider().global_position.z - global_transform.origin.z)
		direction = Vector3(dir_x,0.0, dir_z).normalized()
