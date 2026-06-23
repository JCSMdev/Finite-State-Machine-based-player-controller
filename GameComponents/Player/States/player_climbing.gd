extends PlayerState


@export var climb_duration: float = 0.4 # How fast the climb happens
var target_position: Vector3
var is_climbing: bool = false
var saved_velocity := Vector3.ZERO
func enter() -> void:
	is_climbing = true
	
	player.timers["jump_buffer"].stop()
	saved_velocity = player.velocity
	player.velocity = Vector3.ZERO
	
	var ledge_top : Vector3 = player.raycasts.get_collision_pos()
	
	var forward_direction = Vector3(0,0,1).rotated(Vector3.UP,player.camera.rotation.y)
	target_position = ledge_top - forward_direction*0.2
	spawn_debug_sphere(target_position,Color.RED,0.4,0.5)
	# 4. Start the Climb Animation/Movement using a Tween
	start_climb_tween()

func start_climb_tween() -> void:
	var tween = create_tween().set_parallel(false)
	
	# Step A: Move UP to match the ledge height
	var up_position = Vector3(player.global_position.x, target_position.y, player.global_position.z)
	tween.tween_property(player, "global_position", up_position, climb_duration * 0.6)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_IN)
		
	# Step B: Move FORWARD onto the ledge surface
	tween.tween_property(player, "global_position", target_position, climb_duration * 0.4)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)
		
	tween.finished.connect(_on_climb_finished)

func physics_update(delta: float) -> void:
	# CRITICAL: Do NOT call player.move_and_slide() here! 
	# The Tween is handling positioning. Calling move_and_slide() will make 
	# the physics engine fight the tween and cause horrible jittering.
	pass

func _on_climb_finished() -> void:
	is_climbing = false
	# Return the player back to standard movement logic
	if player.input_direction != Vector2.ZERO:
		player.velocity = saved_velocity
		state_machine.change_state("walking")
	else:
		state_machine.change_state("idle")


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
