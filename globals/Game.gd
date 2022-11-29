extends Node

var playerDamage : float 
var playerMaxMana : float
var playerMana : float
var playerHealth : float 
var playerExp : float

# player abilities
var timestopDuration = 1
var movementSpeed : float = 5.0
var swordRicochet : int = 2  
var swordThrowTime : float = 5.0
var swordThrowDamage : float = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("hitStop", slowTime)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float ) -> void:
	pass

func slowTime(val, time) -> void:
	Engine.time_scale = val
	
	await get_tree().create_timer(time).timeout
	Engine.time_scale = 1
	
