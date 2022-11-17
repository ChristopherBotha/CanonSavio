extends PlayerState

func enter(_msg := {}) -> void:
	if _msg.has("do_dash"):
		owner.dashing = true
		owner.dash()
	
func physics_update(delta: float) -> void:
	
	if owner.velocity.y < 0:
		state_machine.transition_to("Fall", {do_fall = true})
	elif owner.is_on_floor() and owner.dir != Vector3.ZERO and Input.is_action_pressed("sprint") and owner.dashing == false:
		state_machine.transition_to("Run", {do_Run = true})
	elif owner.is_on_floor() and owner.dir != Vector3.ZERO and owner.dashing == false:
		state_machine.transition_to("Walk", {dp_walk = true})
	elif owner.is_on_floor() and owner.dir == Vector3.ZERO and owner.dashing == false:
		state_machine.transition_to("Idle", {do_Idle = true})
	

	pass
	
