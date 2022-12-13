#@tool
extends CharacterBody3D

@onready var dust = $Marker3D/dust
@onready var eyes : Node3D = $eyes
@onready var aimCast : RayCast3D = $eyes/RayCast3D

@onready var blood = preload("res://effects/blood.tscn")
@onready var bullet : PackedScene =  preload("res://weapons/bullet.tscn")

const SPEED : float = 5.0
const JUMP_VELOCITY : float = 4.5
var direction
var witch_time = 1
@onready var healthBar : ProgressBar = $healthBar/SubViewport/ProgressBar
@onready var health : float = 200

var target
var TURN_SPEED : float = 10
var shot : bool = false

@onready var nav_agent = $NavigationAgent3D
var next_location := Vector3.ZERO
var new_velocity := Vector3.ZERO
var current_location := Vector3.ZERO

var player_in_range : bool = false
var player_hit : bool = false
var enemyhurt : bool = false
var player 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:

	pass

func _physics_process(delta: float) -> void:
	
	healthBar.value = health
	
#	if is_on_floor():
#		velocity.y = JUMP_VELOCITY
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta * witch_time
		
	if self != null: #d enemyhurt == false:
		if nav_agent.is_target_reachable() :
			current_location = global_position
			next_location = nav_agent.get_next_location()
			new_velocity = (next_location - current_location).normalized() * SPEED
			nav_agent.set_velocity(new_velocity)
		else:
			nav_agent.set_velocity(Vector3.ZERO)
		
	death()
	shoot()
	
	lookAtPlayer()
	move_and_slide()
	

func hurt(hurt_damage : float, pushBack: float, timeScale : float, hitstopDuration: float) -> void:
	
	var bloody = blood.instantiate()
	get_tree().get_root().add_child(bloody)
	bloody.global_position = global_position 
	bloody.global_rotation = global_rotation
	
	$AnimationPlayer.play("hit")
	health -= hurt_damage
	SignalBus.emit_signal("trauma", 0.8, 0.2)
#	SignalBus.emit_signal("hitStop",timeScale, hitstopDuration)
	
	pushBack()
	velocity = velocity.lerp(direction * 5, pushBack)
	
	await get_tree().create_timer(0.1).timeout
	velocity = Vector3.ZERO
	dust.emitting = false

	
	
func death() -> void:
	if health <= 0:
		await get_tree().create_timer(0.1).timeout
		queue_free()

func playerPos(player : Player) -> void:

	target = player

func lookAtPlayer() -> void:
	if target != null:
		eyes.look_at(target.global_position, Vector3.UP )
		rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED) * witch_time)

func pushBack() -> void:
	dust.emitting = true
	var dir_x = (target.global_position.x - global_transform.origin.x)
	var dir_z = (target.global_position.z - global_transform.origin.z)
	direction = Vector3(dir_x,0.0, dir_z).normalized()
	
func shoot():
	if shot == false: 
		
		shot = true
		
		var bullets = bullet.instantiate()
		get_tree().get_root().add_child(bullets)
		bullets.global_position = $MeshInstance3D/Nozzle.global_position 
		bullets.global_rotation = $MeshInstance3D/Nozzle.global_rotation
		
		await get_tree().create_timer(2 ).timeout
		shot = false


func _on_navigation_agent_3d_navigation_finished():
	pass # Replace with function body.


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if enemyhurt == false:
		velocity = velocity.move_toward(safe_velocity,0.25)


func _on_navigation_agent_3d_target_reached():
	if enemyhurt == false:
		velocity = Vector3.ZERO

func update_target_location(target_location):
	if enemyhurt == false:
		nav_agent.set_target_location(target_location)
