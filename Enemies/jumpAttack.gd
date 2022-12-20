extends Node
# The enemy's movement speed
var speed = 250

# The enemy's jumping height
var jump_height = 200

# The enemy's jumping duration
var jump_duration = 1

# A reference to the player
var player 

# A reference to the enemy's node
var enemy_node

# A flag to indicate if the enemy is currently jumping
var jumping = false

# A timer to track the duration of the jump
var jump_timer = 0

# A curve to control the enemy's jumping motion
var jump_curve = Curve.new()

# Set up the jump curve
func _ready():
	player = self
	print("jumping")
	jump_curve.add_point(Vector2(0, 0), 0)
	jump_curve.add_point(Vector2(0, jump_height), jump_duration / 3)
	jump_curve.add_point(Vector2(0, 0), 2 * jump_duration / 3)
	jump_curve.add_point(Vector2(0, 0), jump_duration)

func _physics_process(delta: float) -> void:
	if owner.target:
		enemy_node = owner.target
	
# A function to make the enemy jump to the player's position

func jump():

	# Check if the enemy is already jumping
	if not jumping:
		# If the enemy is not already jumping, start the jump
		jumping = true
		# Reset the jump timer
		jump_timer = 0

# A function to update the enemy's jumping motion
func update_jump(delta):

	# Check if the enemy is jumping
	if jumping:
		# If the enemy is jumping, increase the jump timer
		jump_timer += delta
		# Calculate the enemy's current position on the jump curve
		var position = jump_curve.interpolate(jump_timer / jump_duration)
		# Update the enemy's position based on the curve
		enemy_node.position += position * delta
		# Check if the jump has finished
		if jump_timer >= jump_duration:
			# If the jump has finished, stop jumping
			jumping = false

# A function to update the enemy's movement
func update_movement(delta):
	# Calculate the distance between the enemy and the player
	var distance = owner.global_position - owner.target.global_position
	# Calculate the direction of the enemy's movement
	var direction = distance.normalized()
	# Update the enemy's position based on its movement speed and direction
	owner.target.global_position += direction * speed * delta

# A function to update the enemy
func update(delta):
	# Update the enemy's jumping motion
	update_jump(delta)
	# Update the enemy's movement
	update_movement(delta)
