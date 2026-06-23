extends PlayerGroundState


func physics_update(delta: float) -> void:
	super(delta)
	if player.input_direction != Vector2.ZERO:
		state_machine.change_state("walking")
	player.velocity.x *= player.STATS.friction
	player.velocity.z *= player.STATS.friction
	player.move_and_slide()
		
