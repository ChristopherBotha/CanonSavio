#@tool
extends CharacterBody3D
class_name Enemy
@onready var jump : Node = $jumpAttack
@export var jumpCurve: Curve
var jump_progress

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

@onready var detectArea = $AreaDetect/CollisionShape3D
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

var attack_range = 3 # The distance at which the enemy will attack the player
var attack_damage = 10 # The damage that the enemy does
var attack_speed = 1 # The enemy's attack speed, in attacks per second
var movement_speed = 400 # The enemy's movement speed
var state # The enemy's current state
var currentState = "idle"

var states = {
	"idle": idle,
#	"patrol": patrol,
	"action": action,
	"stunned": stunned,
	"juggle": juggle,
	"persue": persue
}

var playerPos
var target_position # The enemy's target position
@onready var attack_timer = $Timers/attackTimer # A timer for tracking the duration of the enemy's attacks
var attack_cooldown = 3.0 / attack_speed # The amount of time that the enemy will wait between attacks
@onready var stun_timer = $Timers/stunTimer # A timer for tracking the duration of the enemy's stun state
var stun_duration = 1.0 # The amount of time that the enemy will be stunned

##############################################################################################
# Constants for the weights of the different actions
var weight_attack = 1.0
var weight_heal = 0.5
var weight_defend = 0.75

var attack_utility 
var heal_utility 
var defend_utility 

# The enemy's current health and maximum health
var max_health = 100

# The enemy's current position and the player's position
var enemy_pos
var player_pos

# The distance between the enemy and the player
var distance
var reached = false
# The enemy's attack power and defense
var attack_power = 10
var defense = 5

# The enemy's current state (attacking, defending, etc.)
var actionState = {
	"attacking": attack,
	"healing": heal,
	"defending": defend,
	"fleeing": flee
}
@onready var funcStates = []

var flee_utility

func _ready() -> void:
	actionState = null
	# Set up the attack timer
	attack_timer.wait_time = attack_cooldown
	attack_timer.connect("timeout", _on_attack_timeout)

	stun_timer.wait_time = stun_duration
	stun_timer.connect("timeout", _on_stun_timeout)
  
  # Set the initial state to idle
	set_state("idle")
	
func _process(delta):
	pass
	
func _physics_process(delta: float) -> void:
	
		# Execute the enemy's current state
	states[state].call(delta)
	print(state)
	healthBar.value = health

	if juggleState == true and not is_on_floor():
		velocity.y -= gravity * 0.2 * delta * witch_time
	elif not is_on_floor():
		velocity.y -= gravity * delta * witch_time

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

	if target:
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

func lookAtPlayer() -> void:
	if target:
		eyes.look_at(target.global_position, Vector3.UP )
		rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED) * witch_time)

func pushBack() -> void:
	dust.emitting = true
	if target:
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
		set_state("action")

func update_target_location(target_location):
	if enemyhurt == false:
		nav_agent.target_position = target_location
		playerPos = target_location

func set_state(new_state):
  # Set the enemy's state and reset any relevant timers or variables
	state = new_state
	
	# Handle the new state using a switch statement
	match new_state: 
		"idle":
			attack_timer.stop()
		"action":
			attack_timer.stop()
		"stunned":
			stun_timer.start()
		"dead":
			death()
		"flee":
			# add code here to handle the flee state
			pass


func idle(delta):
  # Check if the player is within range
	
	if !target:
		velocity= Vector3.ZERO
	elif aimCast.get_collider() :
		target = aimCast.get_collider()
		set_state("persue")
#	# Set a random target position and transition to the patrol state
#		target = lerp(global_position, Vector3(randi_range(-100, 100), 0, randi_range(-100, 100)), 0.2)
#		set_state("patrol")

func persue(delta)-> void:
	if self != null and target != null: #d enemyhurt == false:
		if nav_agent.is_target_reachable() :
			current_location = global_position
			next_location = nav_agent.get_next_path_position()
			new_velocity = (next_location - current_location).normalized() * SPEED
			nav_agent.set_velocity(new_velocity)
		else:
			nav_agent.set_velocity(Vector3.ZERO)
	move_and_slide()


func patrol(delta):
  # Move towards the target position
	var dir = target_position - global_transform.origin
	if dir.length() < movement_speed * delta:
		set_state("idle")
	else:
		move_and_slide()

func action(delta):
	
	if target:
		var dir = target.global_position - global_position
		var distance = dir.length()
		if distance < attack_range:
			set_state("action")
			decide_action(delta)
		else:
			set_state("persue")

func stunned(delta) -> void:
  # Do nothing while the enemy is stunned
	set_physics_process(false)

func _on_attack_timeout() -> void:
  # Return to the idle state when the attack timer runs out
	set_state("idle")

func _on_stun_timeout()-> void:
  # Return to the idle state when the stun timer runs out
	set_physics_process(true)
	set_state("idle")
	print("stunned over")

func take_damage(damage) -> void:
  # Decrement the enemy's health and enter the stun state if necessary
	health -= damage
	if health <= 0:
		queue_free()
	else:
		set_state("stunned")

func juggle(delta) -> void:
	pass


func _on_area_detect_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		target = body
		set_state("persue")


func _on_area_detect_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		target = null
		set_state("idle")


func decide_action(delta):
	
		# Calculate the utility of each action
	# calculate the attack utility
	attack_utility = weight_attack * (attack_power / target.defense)
# calculate the heal utility
	heal_utility = weight_heal * (max_health - health) / max_health
# calculate the defend utility
	defend_utility = weight_defend * defense / target.attack_power
#	flee_utility = WEIGHT_FLEE / distance

# select the action with the highest utility
	if attack_utility > heal_utility and attack_utility > defend_utility:
		attack(delta)
	elif heal_utility > defend_utility:
		heal()
	else:
		defend()


func attack(delta):
	# Set the enemy's state to attacking and reduce the player's health
	actionState = "attacking"
	target.health -= attack_power
	print("i am attacking")

func heal():
	# Set the enemy's state to healing and increase the enemy's health
	actionState = "healing"
	health += max_health * 0.1
	print("i am healing")

func defend():
	# Set the enemy's state to defending
	actionState = "defending"
	print("i am defending")
	
func flee():
	# Set the enemy's state to fleeing and move the enemy away from the player
	actionState = "fleeing"
#	enemy_pos = enemy_pos + (enemy_pos - player_pos).normalized() * 5
	print("i am fleeing")

