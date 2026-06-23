extends HBoxContainer
class_name RebindBtn
const UI_TEXTS = preload("uid://bhb3fseepprxg")


@onready var action_name: Label = $ActionName
@onready var btns: HBoxContainer = $Btns

var inputs : Array[InputEvent] = [null,null]

signal change_key_mapping(action: String, ind: int)

func _ready() -> void:
	var ind = 0
	for btn in btns.get_children():
		if btn is Button:
			btn.pressed.connect(func():
				change_key_mapping.emit(name,ind)
				btns.get_child(ind).text = "Press a Button"
			)
			ind += 1

func change_name(_action_name: String) -> void:
	name = _action_name
	action_name.text = _action_name.capitalize()


func set_input(index: int, event: InputEvent) -> void:
	var btn : Button = btns.get_child(index)
	inputs[index] = event
	if btn:
		if event == null:
			btn.text = UI_TEXTS.UnboundKeyText
		else: 
			btn.text = event.as_text().trim_suffix(" - Physical")
