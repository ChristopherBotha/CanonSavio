extends PlayerState

func enter(_msg := {}) -> void:
		pass
	
	
func physics_update(_delta: float) -> void:
#	owner.velocity = owner.velocity.lerp(Vector3.ZERO, owner.airFriction)

	if owner.is_on_floor() and owner.dir == Vector3.ZERO:
		state_machine.transition_to("Idle", {do_Idle = true})
		owner.sprinting = false
		owner.sprintFalse()
		
	pass
	
