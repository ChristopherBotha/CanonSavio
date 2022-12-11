extends CharacterBody3D
class_name Player

####   #####  ####   #    #   ####
#   #  #      #   #  #    #  #
#   #  ####   ####   #    #  #  ####
#   #  #      #   #  #    #  #    #
####   #####  ####    ####    ####

# check for progress of player guages
@onready var mana : float = 100:
	set(new_value): 
		mana = clamp(new_value,0,100)
		SignalBus.emit_signal("manaUpdated", mana)

@onready var exVal : float = 0.0:
	set(new_value): 
		exVal = clamp(new_value,0,100)
		SignalBus.emit_signal("exBarValue", exVal)

@onready var health : float = 100:
	set(new_value): 
		health = clamp(new_value,0,100)
		SignalBus.emit_signal("healthUpdated", health)

# check state of actions
@onready var attacking : bool = false:
	set(new_value): 
		SignalBus.emit_signal("attackingUpdated", new_value)
		attacking = new_value
		SignalBus.emit_signal("attackingUpdated", attacking)

@onready var EX : bool = false:
	set(new_value): 
		EX = new_value
		SignalBus.emit_signal("exBarUpdated", EX)

@onready var dashing : bool = false:
	set(new_value): 
		dashing = new_value
		SignalBus.emit_signal("dashingUpdated", new_value)
		
@onready var sprinting : bool = false:
	set(new_value): 
		sprinting = new_value
		SignalBus.emit_signal("sprintingUpdated", new_value)
		
@onready var jumping : bool = false:
	set(new_value): 
		jumping = new_value
		SignalBus.emit_signal("jumpingUpdated", new_value)

@onready var sword_sheathed : bool = true:
	set(new_value): 
		sword_sheathed = new_value
		SignalBus.emit_signal("swordSheathedUpdated", sword_sheathed)
		
@onready var SPEED : float = 5.0:
	set(new_value): 
		SPEED = new_value
		SignalBus.emit_signal("speedUpdated", SPEED)
		
@onready var JUMP_VELOCITY : float = 4.5:
	set(new_value): 
		JUMP_VELOCITY = new_value
		SignalBus.emit_signal("jumpVelUpdated", new_value)
		
@onready var dashSpeed : int = 200:
	set(new_value):
		dashSpeed = new_value
		SignalBus.emit_signal("dashSpeedUpdated", new_value)
