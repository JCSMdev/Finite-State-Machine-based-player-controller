extends PlayerAirbornState


var g_mult := 1


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("jump") and player.velocity.y > 0:
		g_mult = player.STATS.release_gravity_multiplier
		

func enter() -> void:
	
	g_mult = 1.0	
	player.timers["jump_buffer"].stop()
	player.timers["coyote"].stop()
	player.velocity.y = max(player.velocity.y,0)
	player.velocity.y += player.STATS.jump_velocity

func physics_update(delta: float) -> void:
	super(delta)
	if not player.is_on_floor():
		player.velocity.y += player.STATS.jump_gravity * g_mult * delta 
	if player.velocity.y < 0:
		state_machine.change_state("falling")
	up_animation(delta)
	player.move_and_slide()

func exit() -> void:
	reset_animation()

func up_animation(delta: float) -> void:
	
	player.skin.scale.y = lerp(player.skin.scale.y,0.6,12*delta)
	player.skin.position.y = lerp(player.skin.position.y,0.65,30*delta)

func reset_animation() -> void:
	var tween = create_tween().set_parallel(false)
	tween.tween_property(player.skin,"scale",Vector3(1,1,1),0.2)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(player.skin,"position",Vector3.ZERO,0.2)
