extends Resource
class_name  PlayerResource


@export_group("Walk")
@export var crouch_speed := 1.0
@export var walk_speed := 2.0
@export var run_speed := 4.0
@export var accel_time := 0.1  # How fast we reach top speed
@export var friction := 0.2    # How fast we stop

@export_group("Jump")
@export var jump_height := 1.5
@export var jump_time_to_peak := 0.3
@export var jump_time_to_descent := 0.27
@export var release_gravity_multiplier := 2.5
var jump_velocity =  (2.0 * jump_height) / jump_time_to_peak
var jump_gravity = (-2.0 * jump_height) / pow(jump_time_to_peak, 2)
var fall_gravity = (-2.0 * jump_height) / pow(jump_time_to_descent, 2)

@export_subgroup("Jump Timers")
@export var jump_buffer_max := 0.1
@export var coyote_max := 0.1
@export var jump_cooldown_max := 0.1

@export_group("Stats")
@export var health := 100.0
@export var slide_floor_angle := 20.0
var slide_floor_rad := deg_to_rad(slide_floor_angle) 
