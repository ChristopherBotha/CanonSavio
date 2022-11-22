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
var TURN_SPEED = 2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):

	if event is InputEventMouseMotion:
		camrot_h -= event.relative.x * h_sensitivity
		camrot_v -= event.relative.y * v_sensitivity
	

func _process(_delta):
	camrot_v = clamp(camrot_v , deg_to_rad(-50), deg_to_rad(50))
	
	if Input.is_action_just_pressed("lock"):
		lock = true
		
	if enemy and lock == true:
		if enemy != null and lock == true:
			if enemy and lock == true:
				$h.look_at(enemy[0].global_transform.origin, Vector3.UP )

				await get_tree().create_timer(0.3).timeout
				if Input.is_action_just_pressed("lock") and lock == true:
					lock = false
					print("hello")
					$h.rotate_y(deg_to_rad(owner.rotation.y * TURN_SPEED))
	else:
		lock = false
		$h.rotate_y(deg_to_rad(owner.rotation.y * TURN_SPEED))
		$h.rotation.y = h_acceleration * camrot_h 
		$h/v.rotation.x = v_acceleration * camrot_v 


func _on_lock_range_body_entered(body):
	if body.is_in_group("Enemies"):
		enemy.append(body)


func _on_lock_range_body_exited(body):
	if body.is_in_group("Enemies"):
		for i in enemy:
			if body == i:
				enemy.erase(i)
			else:
				print("no")
	pass # Replace with function body.
