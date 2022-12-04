extends PlayerState

func enter(_msg := {}) -> void:
	if _msg.has("do_jump"):
		while owner.velocity.y < owner.maxJumpHeight:
			owner.velocity.y += owner.JUMP_VELOCITY
		pass
	
	
func physics_update(_delta: float) -> void:
	
	if owner.attacking == true:
		owner.velocity.y = 0.0
	
	if owner.velocity.y < 0:
		state_machine.transition_to("Fall", {do_Fall = true})
	elif owner.is_on_floor() and owner.dir != Vector3.ZERO and Input.is_action_pressed("sprint"):
		state_machine.transition_to("Run", {do_Run = true})
	elif owner.is_on_floor() and owner.dir != Vector3.ZERO :
		state_machine.transition_to("Walk", {dp_Walk = true})
		owner.sprinting = false
		owner.sprintFalse()
	elif owner.is_on_floor() and owner.dir == Vector3.ZERO:
		state_machine.transition_to("Idle", {do_Idle = true})
		owner.sprinting = false
		owner.sprintFalse()
		
	pass
	
