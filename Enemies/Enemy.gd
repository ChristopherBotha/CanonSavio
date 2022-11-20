extends CharacterBody3D

@onready var eyes = $eyes
@onready var aimCast = $eyes/RayCast3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var direction

@onready var healthBar = $healthBar/SubViewport/ProgressBar
@onready var health : float = 200

var target
var TURN_SPEED = 2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	pass

func _physics_process(delta):
	
	healthBar.value = health
	
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	lookAtPlayer()
	move_and_slide()

	
func hurt(hurt_damage, pushBack) -> void:
	health -= hurt_damage
	
	SignalBus.emit_signal("trauma", 0.5, 0.2)
	SignalBus.emit_signal("hitStop",0.1, 0.05)
	
	pushBack()
	velocity = velocity.lerp(direction * 5, pushBack)
	
	await get_tree().create_timer(0.1).timeout
	velocity = Vector3.ZERO
	
	if health <= 0:
		queue_free()

func playerPos(player) -> void:
	target = player

func lookAtPlayer():
	if target != null:
		eyes.look_at(target.global_position, Vector3.UP )
		rotate_y(deg_to_rad(rotation.y * TURN_SPEED))

func pushBack():
	var dir_x = (target.global_position.x - global_transform.origin.x)
	var dir_z = (target.global_position.z - global_transform.origin.z)
	direction = Vector3(dir_x,0.0, dir_z).normalized()
	
