extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	$MeshInstance3D.visible = false
#	$Area3D/CollisionShape3D.disabled = true
	pass	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("timeZone"):
		$AnimationPlayer.play("grow")
#		$MeshInstance3D.visible = true
#		$Area3D/CollisionShape3D.disabled = false
	pass

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Bullets"):
		area.owner.freeze = true

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("Bullets"):
		area.owner.freeze = false
