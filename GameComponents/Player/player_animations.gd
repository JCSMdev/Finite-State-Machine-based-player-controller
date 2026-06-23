extends Node3D

@export var rotation_speed: float = 20.0
@export var max_tilt_angle: float 
@onready var max_tilt := deg_to_rad(max_tilt_angle)
@export var max_lean_angle: float 
@onready var max_lean := deg_to_rad(max_lean_angle)
@export var tilt_speed: float = 8.0   

var is_sliding := false
var start_pos : Vector3
var player : Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent()
	start_pos = position

func _physics_process(delta: float) -> void:
	var target_tilt: float = 0.0
	var forward_dir := -global_transform.basis.z.normalized()
	var ground_velocity := Vector3(player.velocity.x, 0.0, player.velocity.z)
	
	if player.input_direction != Vector2.ZERO:
		var look_target := ground_velocity if ground_velocity.length_squared() > 0.1	else player.input_rotated
		var look_angle := atan2(look_target.x, look_target.z)
		rotation.y = lerp_angle(
			rotation.y, 
			look_angle, 
			rotation_speed * delta
		)
		
		var target_dir := player.input_rotated
		
		var cross_prod := forward_dir.cross(target_dir)
		target_tilt = -cross_prod.y * max_tilt
		rotation.z = lerp_angle(rotation.z, target_tilt, tilt_speed * delta)
		if not is_sliding:
			rotation.x = lerp_angle(rotation.x, min(max_lean, (ground_velocity.length()/player.STATS.run_speed*0.1)), tilt_speed * delta)
	else:
		if not is_sliding:
			rotation.x = lerp_angle(rotation.x, 0., tilt_speed * delta)
	if is_sliding:
		position = lerp(position,start_pos-forward_dir*0.5-Vector3.UP*0.5,20*delta)
		rotation.x = lerp_angle(rotation.x, deg_to_rad(-60), 20 * delta)
	else:
		position = lerp(position,start_pos,20*delta)

func _on_sliding_on_enter(name: String) -> void:
	is_sliding = true
	print("Slide entered")
	


func _on_sliding_on_exit(name: String) -> void:
	is_sliding = false
