extends CharacterBody3D
class_name Player

const STATS = preload("uid://tvhvtgclhnb8")


@export_group("Components")
@export var camera : PlayerCamera
@onready var skin : Node3D = $PlayerSkin
@onready var JumpTimersNode: Node = $Timers/JumpTimers
@onready var StateMachinesNode: Node = $StateMachines
@onready var raycasts: Node3D = $Raycasts
@onready var collider: CollisionShape3D = $Collider
@onready var state_label: Label3D = $Label3D

var start_pos : Vector3


var state_machines : Dictionary[String,StateMachine] 

var timers : Dictionary[String,Timer] = {}
var was_on_floor := false

var input_direction := Vector2.ZERO
var input_rotated := Vector3.ZERO



func _ready() -> void:
	start_pos = global_position
	for sm in StateMachinesNode.get_children():
		if sm is StateMachine:
			state_machines[sm.name.to_lower()] = sm
			
	for t in JumpTimersNode.get_children():
		if t is Timer:
			var t_name = t.name.to_lower()
			t.wait_time = STATS.get(t_name+"_max")
			timers[t_name] = t

	was_on_floor = is_on_floor()


func _unhandled_input(event: InputEvent) -> void:
	
	# (x,z)
	input_direction = Input.get_vector("move_left", "move_right","move_forward", "move_backward").normalized()
	input_rotated = Vector3(input_direction.x,0,input_direction.y)\
	.rotated(Vector3.UP,camera.rotation.y)
	# (y)
	if event.is_action_pressed("jump"):
		timers["jump_buffer"].start()
		
		
func _physics_process(delta: float) -> void:
	state_label.text = "{0}".format([state_machines["movement"].current_state.name,
	])
	
	if global_position.y < -20:
		global_position = start_pos
		velocity = Vector3.ZERO

	
