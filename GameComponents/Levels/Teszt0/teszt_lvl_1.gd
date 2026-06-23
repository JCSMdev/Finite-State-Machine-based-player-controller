extends Node3D

var is_paused := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

signal paused

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit_mouse"):
		Engine.time_scale = 0
		is_paused = true
		paused.emit()
	if event.is_action_pressed("slowdown_time"):
		Engine.time_scale = max(Engine.time_scale-0.1,0.1)
	if event.is_action_pressed("speedup_time"):
		Engine.time_scale = min(Engine.time_scale+0.1,1.0)

func _on_h_slider_value_changed(value: float) -> void:
	Engine.time_scale = value


func _on_button_pressed() -> void:
		Engine.time_scale = 1
		is_paused = false
