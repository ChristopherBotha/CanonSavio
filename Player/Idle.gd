extends PlayerState

func enter(_msg := {}) -> void:
		pass
	
	
func physics_update(_delta: float) -> void:
	
	if owner.dir != Vector3.ZERO and Input.is_action_pressed("sprint"):
		state_machine.transition_to("Run",{do_run = true})
	elif Input.is_action_just_pressed("attack"):
		state_machine.transition_to("Attack",{do_attack = true})
	elif Input.is_action_just_pressed("attack2"):
		state_machine.transition_to("Attack2",{do_attack = true})
	elif owner.dir != Vector3.ZERO:
		state_machine.transition_to("Walk", {do_walk = true})
	elif Input.is_action_just_pressed("jump"):
		print("jump")
		state_machine.transition_to("Jump", {do_jump = true})
	elif Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash", {do_dash = true})
	elif owner.velocity.y < 0:
		state_machine.transition_to("Fall", {do_fall = true})
	
