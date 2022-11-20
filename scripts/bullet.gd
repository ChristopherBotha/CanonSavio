extends RigidBody3D

var shoot = false
const SPEED = 100
const DAMAGE = 20
const ARMOR_DAMAGE = 10
var shot

func _ready():
	set_as_top_level(true)
	
func _physics_process(_delta):
	if shoot:
		apply_impulse(-transform.basis.z, -transform.basis.z * SPEED)

func queueFree():
	
	await get_tree().create_timer(5).timeout
	self.queue_free()

func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemies"):
		if body.has_method("hurt"):
			body.hurt(DAMAGE, -3)
			self.queue_free()
		else:
			self.queue_free()
			
	pass # Replace with function body.
