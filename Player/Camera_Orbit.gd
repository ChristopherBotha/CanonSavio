extends Node3D

var camrot_h = 0
var camrot_v = 0
var h_sensitivity = 0.001
var v_sensitivity = 0.001
var h_acceleration = 1
var v_acceleration = 1

var enemy = []
var lock : bool = false

var mouseDelta : Vector2 = Vector2()
var TURN_SPEED = 10

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):

	if event is InputEventMouseMotion:
		camrot_h -= event.relative.x * h_sensitivity
		camrot_v -= event.relative.y * v_sensitivity
	

func _process(_delta):

	camrot_v = clamp(camrot_v , deg_to_rad(-20), deg_to_rad(20))
	
	if Input.is_action_just_pressed("lock"):
		lock = true
		
	if enemy != null and lock == true:
		if enemy:
			$h.look_at(enemy[0].global_transform.origin, Vector3.UP)
		#		owner.eyes.look_at(enemy[0].global_position, Vector3.UP)
		#		$h.rotate_y(deg_to_rad(owner.eyes.rotation.y))
			
			await get_tree().create_timer(0.3).timeout
			if Input.is_action_just_pressed("lock") and lock == true:
				lock = false
				$h.rotate_y(deg_to_rad(owner.rotation.y * TURN_SPEED))
		#		owner.camera.look_at(owner.global_position, enemy.global_position)
		#			enemy.eyes.look_at(enemy.target.global_transform.origin, Vector3.UP)
		#			enemy.rotate_y(deg_to_rad(enemy.eyes.rotation.y * enemy.TURN_SPEED))
		elif enemy == null:
			lock = false
		
	else:
		$h.rotation.y = h_acceleration * camrot_h 
		$h/v.rotation.x = v_acceleration * camrot_v 


func _on_lock_range_body_entered(body):
	if body.is_in_group("Enemies"):
		enemy.append(body)
		print(enemy)


func _on_lock_range_body_exited(body):
	if body.is_in_group("Enemies"):
		for i in enemy:
			if body == i:
				enemy.erase(i)
				print(enemy)
			else:
				print("no")
	pass # Replace with function body.
