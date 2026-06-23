extends PanelContainer
const TIMED_BUTTON = preload("uid://dokoy5yqck5of")
@onready var key_list: ScrollContainer = $VBoxContainer/ScrollContainer
@onready var warning_container: VBoxContainer = $Warnings/WarningContainer

@export var max_warnings : int = 1
var warnings_count : int = 0


func _ready() -> void:
	key_list.connect("used_key_warning",func(): spawn_warning("Csere"))

func spawn_warning(text: String) -> void:
	if warnings_count < max_warnings:
		var warning := TIMED_BUTTON.instantiate()
		warning.set_message(text)
		warning.connect("pressed",func(d:bool): 
			if d: key_list.switch_key()
		)
		warning.connect("tree_exited",_btn_destroyed)
		warning_container.add_child(warning)
		warnings_count += 1
	
func _btn_destroyed() -> void:
	warnings_count -= 1
