extends PlayerGroundState

var speed : float

func enter() -> void:
	speed = player.STATS.run_speed if Input.is_action_pressed("run") else player.STATS.walk_speed

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("run"): speed = player.STATS.run_speed
	if event.is_action_released("run"): speed = player.STATS.walk_speed
	if event.is_action_pressed("slide"): state_machine.change_state("sliding")
		
func physics_update(delta: float) -> void:
	super(delta)
	
	var input_dir = player.input_direction
	if input_dir == Vector2.ZERO: state_machine.change_state("idle")
	
	player.velocity += get_velocity_to_add(input_dir)*player.STATS.accel_time*delta
	
	if (player.velocity*Vector3(1,0,1)).length() > speed:
		player.velocity.x *= player.STATS.friction
		player.velocity.z *= player.STATS.friction

	player.move_and_slide()
	
## Adding velocity in the input direction based on current velocity
func get_velocity_to_add(input_dir: Vector2) -> Vector3:
	var ground_velocity := player.velocity*Vector3(1,0,1)
	var gv_len := ground_velocity.length()
	
	gv_len = max(gv_len, player.input_rotated.length()*speed)
	# Moving from ground velocity in the direction of target veocity
	return player.input_rotated*gv_len - ground_velocity
