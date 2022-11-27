extends Area3D

var zoned : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.visible = false
	$CollisionShape3D.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# ze worlddddooooo
	if Input.is_action_just_pressed("timeZone") and zoned == false:
		zoned = true
		$AnimationPlayer.play("grow")
		$MeshInstance3D.visible = true
		$CollisionShape3D.disabled = false
		
		await get_tree().create_timer(1).timeout
		zoned = false
		$AnimationPlayer.play("RESET")
		$MeshInstance3D.visible = false
		$CollisionShape3D.disabled = true

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Bullets"):
		area.owner.freeze = true

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("Bullets"):
		area.owner.freeze = false


func _on_body_entered(body: Node3D) -> void:
	print(body)
	if body.is_in_group("Enemies"):
		body.set_physics_process(false)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Enemies"):
		body.set_physics_process(true)
