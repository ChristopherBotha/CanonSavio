extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var health
# The player character
var player

# The distance at which the enemy will attack the player
var attack_range = 50

# The damage that the enemy does
var attack_damage = 10

# The enemy's attack speed, in attacks per second
var attack_speed = 1

# The enemy's movement speed
var movement_speed = 400

# The enemy's current state
var state

# The enemy's target position
var target_position

# A timer for tracking the duration of the enemy's attacks
var attack_timer

# The amount of time that the enemy will wait between attacks
var attack_cooldown = 1.0 / attack_speed

# A timer for tracking the duration of the enemy's stun state
var stun_timer

# The amount of time that the enemy will be stunned
var stun_duration = 1.0

func _ready():
  # Set up the attack timer
  attack_timer = Timer.new()
  attack_timer.wait_time = attack_cooldown
  attack_timer.connect("timeout", self, "_on_attack_timeout")
  
  # Set up the stun timer
  stun_timer = Timer.new()
  stun_timer.wait_time = stun_duration
  stun_timer.connect("timeout", self, "_on_stun_timeout")
  
  # Set the initial state to idle
  set_state("idle")

func _process(delta):
  # Update the attack timer
  attack_timer.start()
  
  # Update the stun timer
  stun_timer.start()
  
  # Execute the enemy's current state
  if state == "idle":
	idle(delta)
  elif state == "patrol":
	patrol(delta)
  elif state == "attack":
	attack(delta)
  elif state == "stunned":
	stunned(delta)

func set_state(new_state):
  # Set the enemy's state and reset any relevant timers or variables
  state = new_state
  if state == "idle":
	attack_timer.stop()
  elif state == "attack":
	attack_timer.stop
	
func idle(delta):
  # Check if the player is within range
  var direction = player.get_global_transform().origin - get_global_transform().origin
  var distance = direction.length()
  if distance < attack_range:
	set_state("attack")
  else:
	# Set a random target position and transition to the patrol state
	target_position = get_global_transform().origin + Vector3(randi_range(-100, 100), 0, randi_range(-100, 100))
	set_state("patrol")

func patrol(delta):
  # Move towards the target position
  var direction = target_position - get_global_transform().origin
  if direction.length() < movement_speed * delta:
	set_state("idle")
  else:
	move_and_slide()

func attack(delta):
  # Attack the player if they are within range and the attack timer is not on cooldown
  if attack_timer.time_left == 0:
	var direction = player.get_global_transform().origin - get_global_transform().origin
	var distance = direction.length()
	if distance < attack_range:
	  player.take_damage(attack_damage)
	  attack_timer.start()

func stunned(delta):
  # Do nothing while the enemy is stunned
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


