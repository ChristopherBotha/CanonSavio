extends PlayerState

func enter(_msg := {}) -> void:
		pass
	
	
func physics_update(delta: float) -> void:
	
	owner.handleInput(delta)
	
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump", {do_jump = true})
	elif owner.dir != Vector3.ZERO and Input.is_action_pressed("sprint"):
		state_machine.transition_to("Run",{do_run= true})
	elif owner.dir == Vector3.ZERO:
		state_machine.transition_to("Idle", {do_Idle = true})
	elif Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash", {do_dash = true})
	pass
	
