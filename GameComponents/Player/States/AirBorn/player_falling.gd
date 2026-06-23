extends PlayerAirbornState

func enter() -> void:
	pass
		
func physics_update(delta: float) -> void:
	super(delta)
	if player.is_on_floor():
		if player.input_direction == Vector2.ZERO: 
			state_machine.change_state("idle")
		elif Input.is_action_pressed("slide"):
			state_machine.change_state("sliding")
		else:
			state_machine.change_state("walking")
	else:
		player.velocity.y += player.STATS.fall_gravity * delta

		player.move_and_slide()

func exit() -> void:
	player.timers["jump_cooldown"].start()
