extends Player

#@onready var bullet = preload("res://weapons/bullet_body.tscn")
@onready var timeZone = $timeZone
@onready var nozzle : Node3D = $Body/nozzle
@onready var chainCast : RayCast3D = $Body/chainCast
@onready var dust = $Body/dust/dust
@onready var colorEX = $ColorInvert
@export var backSheathe : Node3D
@export var equipSword : Node3D
@onready var exTimer : Timer = $exTimer


var menu : bool = false
var direction # direction which player is facing

var myEquip  : Dictionary = { 
	0: "sword",
	1: "gun"
}

var shot : bool = false

var guns : Dictionary = {
	"machineGun": machineGun(),
	"magNum": magNum(),
	"shotGun": shotGun()
}


@onready var eyes : Node3D = $eyes
@onready var playback = $AnimationTree.get("parameters/playback")

@onready var aimCast : RayCast3D= $Camera_Orbit/h/v/SpringArm3D/Camera3D/RayCast3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var maxSpeed : float = 15.0
@export var minSpeed : float = 5.0
var maxJumpHeight : float = 6
var dir : Vector3 = Vector3.ZERO
var momentum : float = 0.1
var friction : float = 0.05
var airFriction : float = 0.07

@onready var sword = $Body/Back/holsterSword/Axe
@onready var state_name : State_Machine = $State_Machine
@onready var body = $Body
@onready var back : Node3D = $Body/Back
@onready var camera : Camera3D = $Camera_Orbit/h/v/SpringArm3D/Camera3D
@onready var cams : Node3D = $Camera_Orbit
@onready var horRot : Node3D = $Camera_Orbit/h

var h_rot : float

func _ready() -> void:
	SignalBus.emit_signal("attackingUpdated", attacking)
	SignalBus.emit_signal("swordSheathedUpdated", sword_sheathed)
	SignalBus.emit_signal("speedUpdated", SPEED)
	SignalBus.emit_signal("playerStateName", state_name.state.name)
	SignalBus.emit_signal("speedUpdated", SPEED)
	
	$TextureRect3.visible = false

func _physics_process(delta: float) -> void:
	
	SignalBus.emit_signal("playerStateName", state_name.state.name)
	
	exMode()
	
	print(attacking)
	
	if !is_on_floor():
		velocity.y -= gravity * delta
		
	_sheath()
	chainCastCollide()
	pushBack()
	axeing()
	shoot()
	sprintFalse()
	handleInput(delta)
	handle_animaton()
	move_and_slide()


func handleInput(delta: float) -> void:
	
	h_rot = $Camera_Orbit/h.global_transform.basis.get_euler().y
	
	var input_dir = Vector3(Input.get_action_strength("right") - Input.get_action_strength("left"),0,
				Input.get_action_strength("down") - Input.get_action_strength("up")).rotated(Vector3.UP, h_rot).normalized()

	dir = input_dir
	dusting()
	
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


func sprint() -> void:
	if Input.is_action_pressed("sprint") and dir != Vector3.ZERO:
		SPEED = maxSpeed
		camera.near = move_toward(camera.near, 0.5, 0.02)
	else :
		sprinting = false


func sprintFalse() -> void:
	if sprinting == false or !Input.is_action_pressed("sprint"):
		SPEED = minSpeed
		camera.near = move_toward(camera.near, 0.8, 0.02)


func dash() -> void:
	if dashing == true and is_on_floor():
		SignalBus.emit_signal("delayChange")
		var direction : Vector3 = _get_direction()
		camera.near = move_toward(camera.near, 0.5, 0.02)
		if dir != Vector3.ZERO:
			velocity = Vector3(direction.x, 0.0, direction.z) * dashSpeed
			velocity = velocity.lerp(Vector3.ZERO, 0.2 ) 
		elif dir == Vector3.ZERO:
			velocity = Vector3(direction.x, 0.0, direction.z) * (dashSpeed - 20)
			velocity = velocity.lerp(Vector3.ZERO, 1.3) 

		await get_tree().create_timer(1).timeout
		camera.near = move_toward(camera.near, 0.8, 0.02)
		dashing = false
		
	else: 
		SPEED = 5.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		if menu == false:
			menu = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif menu == true:
			menu = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
func handle_animaton() -> void:
	
	for j in state_name.get_children():
		if state_name.state.name == j.get_name():
			playback.travel(state_name.state.name)


func hurt(hurt_damage : float, pushBack, timeScale : float, hitstopDuration: float)-> void:
	health -= hurt_damage


func _on_hit_box_body_entered(body):
	if body.is_in_group("Enemies"):
		if body.has_method("hurt"):
			body.hurt(50, -15, 0.1,0.1)


func attackingFalse()-> void:
	attacking = false


func machineGun()-> void:
	pass


func magNum() -> void:

	var DAMAGE : float = 50

	if shot == true and aimCast.get_collider() != null:
		if aimCast.get_collider().is_in_group("Enemies"):
			if aimCast.get_collider() .has_method("hurt"):
				aimCast.get_collider() .hurt(DAMAGE, -15, 0.1,0.01)

func shotGun()-> void:
	pass
	

func shoot() -> void:

	if Input.is_action_just_pressed("shoot") and shot == false:
		shot = true
		magNum()
		
		await get_tree().create_timer(0.5).timeout
		shot = false
		


func pushBack() -> void:
	if aimCast.get_collider() != null:
		var dir_x = (aimCast.get_collider().global_position.x - global_transform.origin.x)
		var dir_z = (aimCast.get_collider().global_position.z - global_transform.origin.z)
		direction = Vector3(dir_x,0.0, dir_z).normalized()


func axeing() -> void:
	if Input.is_action_just_pressed("throw"):
		sword.throw()
		
	if Input.is_action_just_pressed("recall") and sword.state != sword.STATE.HELD:
		sword.recall()


func _get_direction():

	var collision = chainCast.get_collision_point()
	if collision:
		return global_position.direction_to(collision)


func chainCastCollide():
	if aimCast.is_colliding():
		SignalBus.emit_signal("chainCollision", aimCast.get_collider())
		return 


func dusting()-> void:
	if dir != Vector3.ZERO and is_on_floor():
		dust.emitting = true
	else:
		dust.emitting = false
	
func catchAxe()-> void:
	
#	pushBack() 
	var direction : Vector3 = _get_direction()
	
	velocity = Vector3(direction.x, 0.0, direction.z) * 5
	velocity = velocity.lerp(Vector3.ZERO, 1.3) 
	
func exMode() -> void:
	if dir != Vector3.ZERO and EX == false and exVal <= 100:
		exVal += 0.5
		
	if exVal >= 100 and EX == false:
		if Input.is_action_just_pressed("EX"):
			EX = true
			
	if EX == true:
		$TextureRect3.visible = true
		exVal -= 0.2
		$AnimationPlayer.play("ExMode")
		if exVal <= 0:
			$TextureRect3.visible = false
			EX = false
			$ColorInvert.visible = false
			
func _reparent(child: Node, new_parent: Node)-> void:
	var old_parent = child.get_parent()
	old_parent.remove_child(child)
	new_parent.add_child(child)
	
func _unsheath_weapon() -> void:
	if sword.state == sword.STATE.HELD:
		_reparent(get_node("Body/Back/holsterSword").get_child(0), 
				get_node("Body/cherry/Armature/Skeleton3D/hand/hand"))
		sword = $Body/cherry/Armature/Skeleton3D/hand/hand/Axe
		sword.global_position = $Body/cherry/Armature/Skeleton3D/hand/hand.global_position
		sword.global_rotation = $Body/cherry/Armature/Skeleton3D/hand/hand.global_rotation
		
		sword_sheathed = false
		
func _sheath_weapon()-> void:
	if sword.state == sword.STATE.HELD:
		_reparent(get_node("Body/cherry/Armature/Skeleton3D/hand/hand").get_child(0), 
				get_node("Body/Back/holsterSword"))
		sword = $Body/Back/holsterSword/Axe
		sword.global_position = $Body/Back/holsterSword.global_position
		sword.global_rotation = $Body/Back/holsterSword.global_rotation
		
		sword_sheathed = true

func _sheath()-> void:
	if Input.is_action_just_pressed("sheathe"):
		if sword_sheathed == true:
			_unsheath_weapon()
		elif sword_sheathed == false:
			_sheath_weapon()
			
