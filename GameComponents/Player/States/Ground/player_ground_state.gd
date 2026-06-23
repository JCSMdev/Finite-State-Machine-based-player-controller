extends PlayerState
class_name PlayerGroundState

@export var max_step_height: float = 0.5
@export var step_smoothness: float = 20.0
var on_stairs := false
var target_step_y: float = 0.0

func physics_update(delta: float) -> void:
	handle_jump()
	
	# 1. ONLY check for falling if we aren't actively climbing a stair
	if not on_stairs:
		if not player.is_on_floor():
			player.timers["coyote"].start()
			state_machine.change_state("falling")
			return # Exit early so we don't try to handle stairs while falling
			
	handle_stair(delta)

func handle_stair(delta: float) -> void:
	if on_stairs:
		if player.global_position.y >= target_step_y - 0.05:
			on_stairs = false
			return
		
		player.global_position.y = lerp(player.global_position.y, target_step_y, step_smoothness * delta)
		
		if player.velocity.y < 0:
			player.velocity.y = 0
		return # Exit here so we don't re-trigger the initial detection below

	if player.is_on_wall() and player.is_on_floor():
		var ray_fwd: RayCast3D = player.raycasts.rays["stairs_forward"]
		
		if ray_fwd.is_colliding():
			var wall_normal = ray_fwd.get_collision_normal()
			
			if player.input_rotated.dot(-wall_normal) > 0:
				var ray_down: RayCast3D = player.raycasts.rays["stairs_down"]
				
				if ray_down.is_colliding() and ray_down.get_collision_normal().dot(Vector3.UP) > 0.8:
					var step_top_y = ray_down.get_collision_point().y
					var step_height = step_top_y - player.global_position.y
					
					if step_height > 0.05 and step_height <= max_step_height:
						# Lock into the stair state and save our target height
						on_stairs = true
						target_step_y = step_top_y
						
						# Push the player slightly forward over the lip of the step right away
						var forward_dir = -wall_normal
						player.global_position += forward_dir * 0.15


func spawn_debug_sphere(pos: Vector3, color: Color = Color.RED, size: float = 0.2, duration: float = 1.0) -> void:
	# 1. Create a new MeshInstance3D node
	var debug_mesh := MeshInstance3D.new()
	debug_mesh.global_position = pos
	
	# 2. Assign a Sphere shape to it
	var sphere := SphereMesh.new()
	sphere.radius = size / 2.0
	sphere.height = size
	debug_mesh.mesh = sphere
	
	# 3. Give it a bright, unshaded color material (ignores shadows and lighting)
	var mat := ORMMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	debug_mesh.material_override = mat
	
	# 4. Add it directly to the active world scene tree root 
	# (so its position doesn't accidentally move if the player moves)
	get_tree().root.add_child(debug_mesh)
	
	# 5. Automatically destroy the sphere after 'duration' seconds
	get_tree().create_timer(duration).timeout.connect(func(): debug_mesh.queue_free())
