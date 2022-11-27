extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area3D/MeshInstance3D.visible = false
#	$Area3D/CollisionShape3D.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("timeZone"):
		$AnimationPlayer.play("grow")
		$Area3D/MeshInstance3D.visible = true
#		$Area3D/CollisionShape3D.disabled = false


func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("Bullets"):
		body.freeze = true
		print("frozen")
	else:
		print("greets")
