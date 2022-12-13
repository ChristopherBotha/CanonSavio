extends RigidBody3D

var shoot = false
const SPEED = 100
const DAMAGE = 20
const ARMOR_DAMAGE = 10
var shot

func _ready():
	set_as_top_level(true)
	queueFree()
	
func _physics_process(_delta):
	apply_impulse(transform.basis.z, transform.basis.z * SPEED)

func queueFree():
	
	await get_tree().create_timer(5).timeout
	self.queue_free()

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("hurt"):
			body.hurt(DAMAGE, -1, 0.1,0.01)
			self.queue_free()
		else:
			self.queue_free()
	
