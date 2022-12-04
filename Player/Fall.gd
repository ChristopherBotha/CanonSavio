extends PlayerState

func enter(_msg := {}) -> void:
		pass
	
	
func physics_update(delta: float) -> void:
	owner.velocity = owner.velocity.lerp(Vector3.ZERO, owner.airFriction)
	owner.velocity.y -= owner.gravity * delta * 1.2
	
	if owner.is_on_floor() and owner.dir == Vector3.ZERO:
		state_machine.transition_to("Idle", {do_Idle = true})
		owner.sprinting = false
		owner.sprintFalse()
	elif owner.is_on_floor() and owner.dir != Vector3.ZERO:
		state_machine.transition_to("Run", {do_Run = true})
#		owner.sprinting = false
#		owner.sprintFalse()

	
