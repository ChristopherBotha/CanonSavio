extends PlayerState

func enter(_msg := {}) -> void:
	if _msg.has("do_attack"):
		owner.attacking = true 
		pass
	
	
func physics_update(_delta: float) -> void:
	owner.velocity = owner.velocity.lerp(Vector3.ZERO, owner.airFriction)
	if owner.attacking == false and owner.is_on_floor():
		state_machine.transition_to("Idle", {do_Idle = true})
	
	pass
	
