extends Node3D

var victim : Object = null
var chained : bool = false

func _ready():
	SignalBus.connect("chainCollision", collider)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#
	if victim != null:
		if victim.is_in_group("Enemies") and chained == false:
			if Input.is_action_just_pressed("chain") and victim != null:
				SignalBus.emit_signal("trauma",1.0,0.2)
				chained = true
				
				await get_tree().create_timer(3).timeout
				victim = null
				chained = false

	if victim != null and chained == true:
		if abs(victim.global_position.distance_to(global_position)) < 3:
			victim = null
			chained = false
		else:
			victim.global_position = victim.global_position.lerp(owner.global_position, 0.5)


func collider(val: Object) -> void:
	if val.is_in_group("Enemies"):
		victim = val
