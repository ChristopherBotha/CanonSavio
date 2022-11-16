extends Node3D

var camrot_h = 0
var camrot_v = 0
var h_sensitivity = 0.001
var v_sensitivity = 0.001
var h_acceleration = 1
var v_acceleration = 1

var mouseDelta : Vector2 = Vector2()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		camrot_h -= event.relative.x * h_sensitivity
		camrot_v -= event.relative.y * v_sensitivity


func _process(_delta):

	camrot_v = clamp(camrot_v , deg_to_rad(-20), deg_to_rad(20))
	
	$h.rotation.y = h_acceleration * camrot_h 
	$h/v.rotation.x = v_acceleration * camrot_v 
