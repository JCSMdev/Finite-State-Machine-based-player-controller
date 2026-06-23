extends PlayerGroundState

var speed: float
@onready var slide_timer: Timer = $"../../../../Timers/SlideTimer"

# Variables to store the original collider state
var original_height: float 
var original_y_pos: float

var can_slide = false

func _ready() -> void:
	#slide_timer.timeout.connect(timeout)
	pass
func enter() -> void:
	super()
	slide_timer.start()
	can_slide = true
	var bossted_vel := player.velocity *  Vector3(1.15,1,1.15)
	if bossted_vel.length_squared() < 300.:
		player.velocity = bossted_vel
		
	speed = 0
	
	original_height = player.collider.shape.height
	original_y_pos = player.collider.position.y
	
	player.collider.shape.height = original_height * 0.5
	
	player.collider.position.y = original_y_pos - (original_height * 0.25)

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("slide"): 
		state_machine.change_state("walking")
		
func physics_update(delta: float) -> void:
	super(delta)
	print(moving_uphill())
	var input_dir = player.input_direction
	
		
	var velocity_rotated := rotate_velocity()
	
	player.velocity = velocity_rotated
	if player.is_on_floor():
		var can_slide = not moving_uphill()

		
	if moving_uphill():
		add_friction(10)
	elif player.get_floor_normal().dot(Vector3.UP) > 0.9:
		add_friction(8)
	else:
		player.velocity *= 1.01
	player.move_and_slide()

func add_friction(power: float ) -> void:
	# Power is the exact amount of speed units to drop per second (e.g., 10.0)
	var y_vel = player.velocity.y
	var ground_vel = player.velocity * Vector3(1, 0, 1)
	
	# Linearly bring the velocity closer to zero
	ground_vel = ground_vel.move_toward(Vector3.ZERO, power * get_physics_process_delta_time())
	
	player.velocity = ground_vel + Vector3(0, y_vel, 0)

func rotate_velocity() -> Vector3:
	if player.velocity.is_zero_approx() or player.input_direction == Vector2.ZERO:
		return player.velocity
	var current_dir_2d := Vector2(player.velocity.x, player.velocity.z).normalized()
	
	var input_dir := Vector2(player.input_rotated.x,player.input_rotated.z)
	
	var angle := -current_dir_2d.angle_to(input_dir)
	return player.velocity.rotated(Vector3.UP,angle*0.25)
	
func exit() -> void:
	super()
	var ground_velocity := player.velocity * Vector3(1, 0, 1)
	player.velocity = player.input_rotated * ground_velocity.length() + player.velocity*Vector3.UP
	# 4. Restore the original collider size and position
	player.collider.shape.height = original_height
	player.collider.position.y = original_y_pos


func moving_uphill() -> bool:
	return player.velocity.normalized().dot(player.get_floor_normal()) < -0.05
