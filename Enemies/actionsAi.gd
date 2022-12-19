extends Node

# A list of available attack actions that the enemy can perform
var attack_actions = [MeleeAttackAction, RangedAttackAction, SpecialAttackAction]

# The current attack action being executed by the enemy
var current_attack_action = null

var melee_attack_reward
var ranged_attack_reward 
var special_attack_reward 

# A reference to the enemy's health
var health = 100

var distance_to_player = 0
# The threshold at which the enemy will start using special attacks
var special_attack_threshold = 50

func _process(delta):
	# Check if the enemy is currently executing an attack action
	if current_attack_action != null:
		# If the action is still valid, continue executing it
		if current_attack_action.is_valid():
			current_attack_action.execute(delta)
		else:
			# If the action is no longer valid, reset the current action to null
			current_attack_action = null
	
	# If the enemy is not currently executing an attack action, select a new one
	if current_attack_action == null:
		# Calculate the rewards for each attack action
		melee_attack_reward = calculate_melee_attack_reward()
		ranged_attack_reward = calculate_ranged_attack_reward()
		special_attack_reward = calculate_special_attack_reward()
		
		# Select the attack action with the highest reward
		if melee_attack_reward > ranged_attack_reward and melee_attack_reward > special_attack_reward:
			current_attack_action = MeleeAttackAction.new()
		elif ranged_attack_reward > special_attack_reward:
			current_attack_action = RangedAttackAction.new()
		else:
			current_attack_action = SpecialAttackAction.new()

# Calculate the reward for the melee attack action
func calculate_melee_attack_reward():
	# Calculate the reward based on the enemy's health and other factors
	var reward = 0
	
	# Higher reward if the enemy is close to the player
	if distance_to_player < 50:
		reward += 100
	
	return reward

# Calculate the reward for the ranged attack action
func calculate_ranged_attack_reward():
	# Calculate the reward based on the enemy's health and other factors
	var reward = 0
	
	# Higher reward if the enemy is far from the player
	if distance_to_player > 100:
		reward += 100
	
	return reward

# Calculate the reward for the special attack action
func calculate_special_attack_reward():
	# Calculate the reward based on the enemy's health and other factors
	var reward = 0
	
	# Higher reward if the enemy's health is low
	reward += (100 - health) * 0.1
	
	# Higher reward if the enemy's health is above the special attack threshold
	if health > special_attack_threshold:
		reward += 100
	
	return reward

# MeleeAttackAction is a class representing the enemy's melee attack action
class MeleeAttackAction:
	# Execute the melee attack action
	func execute(delta):
		# Perform the melee attack
		print("Enemy is performing a melee attack!")

# RangedAttackAction is a class representing the enemy's ranged attack action
class RangedAttackAction:
	# Execute the ranged attack action
	func execute(delta):
		# Perform the ranged attack
		print("Enemy is performing a ranged attack!")

# SpecialAttackAction is a class representing the enemy's special attack action
class SpecialAttackAction:
	# Execute the special attack action
	func execute(delta):
		# Perform the special attack
		print("Enemy is performing a special attack!")
