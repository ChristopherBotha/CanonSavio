extends Node3D

var distance
var victim = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $RayCast3D.get_collider():
		if Input.is_action_pressed("chain"):
			distance = transform.origin.distance_to($RayCast3D.get_collision_point())
			$Scaler.scale.z = distance 
			if victim != null:
				victim.global_position = victim.global_position.lerp(owner.global_position, 0.3)
		else:
			$Scaler.scale.z = 0.01
			



func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemies"):

		victim = body

func _on_area_3d_body_exited(body):
	if body.is_in_group("Enemies"):
		victim = null
	pass # Replace with function body.
