extends PanelContainer

@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $MarginContainer/Container/ProgressBar
@onready var button: Button = $MarginContainer/Button

signal pressed(data: bool)

var btn_txt := ""

func _ready() -> void:
	timer.timeout.connect(func(): 
		pressed.emit(false)
		_destroy()
	)
	button.connect("pressed",func(): 
		pressed.emit(true)
		_destroy()
		)
	progress_bar.max_value = timer.wait_time
	progress_bar.value = progress_bar.max_value
	button.text = btn_txt

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		progress_bar.value -= delta

func set_message(message: String) -> void:
	btn_txt = message

func _destroy() -> void:
	button.disabled = true
	hide()
	queue_free()
