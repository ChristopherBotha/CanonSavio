#@tool
extends CharacterBody3D

@onready var dust = $Marker3D/dust
@onready var eyes : Node3D = $eyes
@onready var aimCast : RayCast3D = $eyes/RayCast3D

@onready var blood = preload("res://effects/blood.tscn")
@onready var bullet : PackedScene =  preload("res://weapons/bullet.tscn")

@onready var juggleState: bool = false

const SPEED : float = 5.0
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

var attack_range = 50 # The distance at which the enemy will attack the player
var attack_damage = 10 # The damage that the enemy does
var attack_speed = 1 # The enemy's attack speed, in attacks per second
var movement_speed = 400 # The enemy's movement speed
var state # The enemy's current state

var states = {
	"idle": idle,
	"patrol": patrol,
	"attack": attack,
	"stunned": stunned,
	"juggle": juggle
}

var target_position # The enemy's target position
@onready var attack_timer = $Timers/attackTimer # A timer for tracking the duration of the enemy's attacks
var attack_cooldown = 1.0 / attack_speed # The amount of time that the enemy will wait between attacks
@onready var stun_timer = $Timers/stunTimer # A timer for tracking the duration of the enemy's stun state
var stun_duration = 1.0 # The amount of time that the enemy will be stunned

func _ready() -> void:
	# Set up the attack timer
	attack_timer.wait_time = attack_cooldown
	attack_timer.connect("timeout", _on_attack_timeout)

	stun_timer.wait_time = stun_duration
	stun_timer.connect("timeout", _on_stun_timeout)
  
  # Set the initial state to idle
	set_state("idle")

func _process(delta):
	attack_timer.start()
	stun_timer.start()
	# Execute the enemy's current state
	states[state]
	print(state)
	
func _physics_process(delta: float) -> void:
	
	healthBar.value = health
	
	if juggleState == true and not is_on_floor():
		velocity.y -= gravity * 0.2 * delta * witch_time
	elif not is_on_floor():
		velocity.y -= gravity * delta * witch_time
		
	if self != null and player != null: #d enemyhurt == false:
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
	SignalBus.emit_signal("hitStop",timeScale, hitstopDuration)
	

	pushBack()
	velocity = velocity.lerp(direction * 5, pushBack)
	
	await get_tree().create_timer(0.1).timeout
	velocity = Vector3.ZERO
	dust.emitting = false
	
	set_state("stunned")

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
		set_state("attack")

func update_target_location(target_location):
	if enemyhurt == false:
		nav_agent.set_target_location(target_location)
		player = target_location

func set_state(new_state):
  # Set the enemy's state and reset any relevant timers or variables
	state = new_state
	if state == "idle":
		attack_timer.stop()
	elif state == "attack":
		attack_timer.stop()
	elif state == "stunned":
		stun_timer.start()
	elif state == "dead":
	# Perform any necessary cleanup or animation when the enemy dies
		pass
	elif state == "flee":
		# Set a random target position and start moving towards it
		target_position = global_transform.origin + Vector3(randi_range(-100, 100), 0, randi_range(-100, 100))
		move_and_slide()
	elif state == "pursue":
		# Set the target position to the player's current position and start moving towards it
		target_position = player.global_transform.origin
		move_and_slide()
		
func idle(delta):
  # Check if the player is within range
	var dir = player.global_transform.origin - global_transform.origin
	var distance = dir.length()
	if distance < attack_range:
		set_state("attack")
	else:
	# Set a random target position and transition to the patrol state
		target_position = global_transform.origin + Vector3(randi_range(-100, 100), 0, randi_range(-100, 100))
		set_state("patrol")

func persue(delta)-> void:
	
	pass

func patrol(delta):
  # Move towards the target position
	var dir = target_position - global_transform.origin
	if dir.length() < movement_speed * delta:
		set_state("idle")
	else:
		move_and_slide()

func attack(delta):
  # Attack the player if they are within range and the attack timer is not on cooldown
	if attack_timer.time_left == 0:
		var dir = player.global_transform.origin - global_transform.origin
		var distance = dir.length()
		if distance < attack_range:
			player.take_damage(attack_damage)
			attack_timer.start()

func stunned(delta):
  # Do nothing while the enemy is stunned
	player = null
	pass

func _on_attack_timeout():
  # Return to the idle state when the attack timer runs out
	set_state("idle")

func _on_stun_timeout():
  # Return to the idle state when the stun timer runs out
	set_state("idle")

func take_damage(damage):
  # Decrement the enemy's health and enter the stun state if necessary
	health -= damage
	if health <= 0:
		queue_free()
	else:
		set_state("stunned")

func juggle(delta):
	pass
