extends PlayerState

func enter(_msg := {}) -> void:
	if _msg.has("do_run"):
		owner.sprinting = true
	
func physics_update(_delta: float) -> void:
	
	owner.sprint()
	
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump", {do_jump = true})
	elif owner.dir != Vector3.ZERO  and owner.sprinting == false:
		state_machine.transition_to("Walk", {do_walk = true})
	elif owner.dir == Vector3.ZERO and owner.sprinting == false:
		state_machine.transition_to("Idle")
	elif Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash", {do_dash = true})

	
