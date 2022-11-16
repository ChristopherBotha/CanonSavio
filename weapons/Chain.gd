extends Node3D

var distance
var victim = null
var chained : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(chained)
	
	if $RayCast3D.get_collider():
		if Input.is_action_pressed("chain") and chained == false:
			distance = transform.origin.distance_to($RayCast3D.get_collision_point())
			$Scaler.scale.z = distance / 2
			chained = true
			if victim != null :
				victim.global_position = victim.global_position.lerp(owner.global_position, 0.5)
				if victim.global_position == owner.global_position:
					$Scaler.scale.z = 0.001
					await get_tree().create_timer(4).timeout
					victim = null 
					chained = false
			else:
				await get_tree().create_timer(4).timeout
				chained = false
	else:
		$Scaler.scale.z = 0.001
		await get_tree().create_timer(4).timeout
		chained = false



func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemies"):
		victim = body

func _on_area_3d_body_exited(body):
	pass # Replace with function body.
