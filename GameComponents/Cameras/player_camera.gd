extends Node3D

class_name PlayerCamera

@export var target : Player
@export var speed : float
@export var height : float
@export_range(0.01, 1.0) var MouseSensitivity = 0.1
@onready var sensitivity = PI / 180 * MouseSensitivity
@export var MaxTilt: float
@export var MinTilt: float
@onready var tilt_limit_high := deg_to_rad(-MaxTilt)
@onready var tilt_limit_low := deg_to_rad(-MinTilt)

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera_3d: Camera3D = $SpringArm3D/Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position,target.global_position+Vector3.UP*height,speed*delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and \
			Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * sensitivity
		rotation.x += event.relative.y * sensitivity
		rotation.x = clamp(rotation.x, tilt_limit_high, tilt_limit_low)

	if event.is_action_pressed("exit_mouse") and \
			Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
						Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
