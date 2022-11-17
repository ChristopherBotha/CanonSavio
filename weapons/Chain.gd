extends Node3D

var distance
var victim = null
var chained : bool = false

func _ready():
	SignalBus.connect("releaseVictim", releaseVic)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if $RayCast3D.is_colliding():
		if $RayCast3D.get_collider().is_in_group("Enemies") and chained == false:
			victim = $RayCast3D.get_collider()
			if Input.is_action_pressed("chain") :
				SignalBus.emit_signal("trauma",1.0,0.2)
				chained = true
				await get_tree().create_timer(3).timeout
				victim = null
				chained = false

	if victim != null and chained == true:
		victim.global_position = victim.global_position.lerp(owner.hand.global_position, 0.5)

func releaseVic(val):
	victim = val
