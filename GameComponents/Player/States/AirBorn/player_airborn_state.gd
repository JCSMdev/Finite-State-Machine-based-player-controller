class_name PlayerAirbornState extends PlayerState
	
@export var air_acceleration: float = 4.0  # Higher = sharper turns, Lower = floatier
@export var max_air_wish_speed: float = 6.0 # Caps how much speed you can gain purely from air strafing

func physics_update(delta: float) -> void:
	handle_jump()
	handle_aircontrol(delta)

func handle_aircontrol(delta: float) -> void:
	# 1. Get the raw steering velocity needed
	var accel_vector = get_velocity_to_add(player.input_direction)
	
	# 2. Scale it by an acceleration factor and delta
	# Removing .normalized() allows the force to be proportional to input
	player.velocity += accel_vector * air_acceleration * delta
	

func get_velocity_to_add(input_dir: Vector2) -> Vector3:
	# Get current horizontal movement
	var ground_velocity := player.velocity * Vector3(1, 0, 1)
	
	# Calculate what speed the player *wants* to go based on input
	# We cap the maximum speed they can pull themselves towards while mid-air
	var wish_speed = player.input_rotated.length() * max_air_wish_speed
	
	# Target velocity vector based on player's rotated input direction
	var target_velocity = player.input_rotated.normalized() * wish_speed
	
	# Return the difference between where they want to go and where they are going
	return target_velocity - ground_velocity
