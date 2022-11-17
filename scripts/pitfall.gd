extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MeshInstance3D.rotation.y += 0.02
	pass


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.health -= 50
	pass # Replace with function body.
