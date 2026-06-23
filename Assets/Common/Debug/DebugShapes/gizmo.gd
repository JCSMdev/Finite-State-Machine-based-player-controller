extends MeshInstance3D

@export var player: CharacterBody3D  # Drag and drop your player node here in the Inspector
@export var gizmo_size: float = 1.0  # How far the cross lines extend
@export var rotation_speed_modifier: float = 0.5  # Adjust how wildly it spins relative to speed

var current_roll: float = 0.0

func _ready() -> void:
	create_empty_cross_mesh()
	position += Vector3.UP

func _physics_process(delta: float) -> void:
	if player and Vector2(player.velocity.x,player.velocity.z).length() > 0.01:
		# 1. Get player speed and calculate the accumulated rolling rotation
		var player_speed: float = player.velocity.length()
		current_roll += player_speed * rotation_speed_modifier * delta
		
		# 2. Figure out the heading direction from the velocity vector
		# We look at the X and Z velocity to find the horizontal angle
		var heading_angle: float = atan2(player.velocity.x, player.velocity.z)
		
		# 3. Rebuild the transform from scratch to avoid rotation accumulation bugs
		# Start with a clean identity (unrotated) basis
		var new_basis = Basis()
		
		# Apply the heading (Y rotation) so it faces where the player is walking
		new_basis = new_basis.rotated(Vector3.UP, heading_angle)
		
		# Apply the rolling effect (X rotation) relative to that new facing direction
		# This makes it roll forward like a tire along its path of travel
		new_basis = new_basis.rotated(new_basis.x.normalized(), current_roll)
		
		# Apply the calculated orientation back to the gizmo
		global_transform.basis = new_basis

func create_empty_cross_mesh() -> void:
	var im_mesh = ImmediateMesh.new()
	self.mesh = im_mesh
	
	# Create a basic unshaded material so the gizmo is a solid color and ignores scene lighting
	var material = ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true # Allows us to color the lines via code
	self.material_override = material

	# Begin drawing lines
	im_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	# X Axis (Red Line) - This acts as our "axle"
	im_mesh.surface_set_color(Color.RED)
	im_mesh.surface_add_vertex(Vector3(-gizmo_size, 0, 0))
	im_mesh.surface_add_vertex(Vector3(gizmo_size, 0, 0))
	
	# Y Axis (Green Line)
	im_mesh.surface_set_color(Color.GREEN)
	im_mesh.surface_add_vertex(Vector3(0, -gizmo_size, 0))
	im_mesh.surface_add_vertex(Vector3(0, gizmo_size, 0))
	
	# Z Axis (Blue Line) - This points straight forward in the direction of travel
	im_mesh.surface_set_color(Color.BLUE)
	im_mesh.surface_add_vertex(Vector3(0, 0, -gizmo_size))
	im_mesh.surface_add_vertex(Vector3(0, 0, gizmo_size))
	
	im_mesh.surface_end()
