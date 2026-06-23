extends Node3D

var player: Player
var rays: Dictionary[String,RayCast3D] = {}
var pip2 := PI/2

func _ready() -> void:
	player = get_parent()
	for ray in get_children():
		if ray is RayCast3D:
			rays[ray.name.to_lower().trim_suffix("_detector")] = ray

func _physics_process(delta: float) -> void:
	var input_dir := player.input_direction
	if input_dir != Vector2.ZERO:
		var dir := Vector3(input_dir.x,0,input_dir.y)\
		.rotated(Vector3.UP,player.camera.rotation.y).normalized()
		rotation.y = atan2(dir.x, dir.z)

func is_colliding() -> bool:
	var ray := rays["ledge"]
	return ray.is_colliding() and not ray.hit_from_inside
	
func get_collision_pos() -> Vector3:
	var ray := rays["ledge"]
	return ray.get_collision_point()
