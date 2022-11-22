extends RigidBody3D

const SPEED = 100

func _ready():
	set_as_top_level(true)
	
func _physics_process(_delta):
	apply_impulse(-transform.basis.z,transform.basis.z * SPEED)

func queueFree():
	
	await get_tree().create_timer(5).timeout
	self.queue_free()

func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemies"):
		self.queue_free()
	else:
		self.queue_free()

