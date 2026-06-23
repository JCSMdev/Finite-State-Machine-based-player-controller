extends Control
@onready var container: VBoxContainer = $KeyList

const REMAP_BTN = preload("uid://dl1tawuhpgfa")

var current_btn : RebindBtn = null
var previous_event : GameInputAction = null
var current_event : GameInputAction = null
var rebinding := false

## formatted_input : [action_name, btn_index]
var used_inputs : Dictionary[String,Array]= {}

signal used_key_warning()

func _ready() -> void:
	for action_name : StringName in \
	InputMap.get_actions() \
	.filter(func(e: String): return not e.begins_with("ui")):
		
		# Create Remap Btn
		var rmp_btn := REMAP_BTN.instantiate()
		rmp_btn.connect("change_key_mapping",_handle_remap)
		container.add_child(rmp_btn)
		rmp_btn.change_name(action_name)
		
		# Populate button and input library
		var ind: int = 0
		for input : InputEvent in InputMap.action_get_events(action_name):
			var input_name = _format_event(input)
			used_inputs[input_name] = [action_name,ind]
			rmp_btn.set_input(ind,input)
			ind += 1

		# set unbounded text
		for i in range(2-ind): # [0,1]
			rmp_btn.set_input(1-i,null)
		

func _handle_remap(action: String, ind: int) -> void:
	if current_btn != null:
		return
		
	current_btn = container.get_node_or_null(action)
	assert(current_btn,"Action not found")
	
	previous_event = GameInputAction.new()
	previous_event.init(action,ind,current_btn.inputs[ind])
	
	current_event = GameInputAction.new()
	current_event.init(action,ind,null)
	
	rebinding = true
	
func _input(event: InputEvent) -> void:
	#region Errors
	if not rebinding:
		return
	
	# validate
	var is_valid_press = (event is InputEventKey or event is InputEventMouseButton)\
	 and event.is_pressed() 
	if not is_valid_press: 
		return
		
	if event is InputEventMouseButton and event.double_click:
		return
		
	# cancle
	if event.is_action_pressed("ui_cancel"):
		current_btn.set_input(previous_event.action_ind,previous_event.action_event)
		_clear_current()
		return
		
	if event.is_action_pressed("ui_text_delete"):
		_erease_action(previous_event.action_name,previous_event.action_ind,previous_event.action_event)
		current_btn.set_input(previous_event.action_ind,null)
		_clear_current()
		return
	#endregion
	
	if current_event.action_event != null:
		return
	current_event.action_event = event
	
	# already used
	if used_inputs.get(_format_event(current_event.action_event),false):
		used_key_warning.emit()
		return
	
	_safe_rebind()
	get_viewport().set_input_as_handled()

	
	
func _clear_current() -> void:
	rebinding = false
	current_btn = null
	
	previous_event = null
	current_event = null

	

func _safe_rebind() -> void:
	
	var action_name := current_event.action_name
	var ind := current_event.action_ind
	var event := current_event.action_event
	
	used_inputs.get_or_add(_format_event(event),[action_name,ind])
	current_btn.set_input(ind,event)
	InputMap.action_add_event(action_name,event)
	_clear_current()
	
func switch_key() -> void:
	if not rebinding: return
	
	var key : String = _format_event(current_event.action_event)
	var action_to_erease : String = used_inputs[key][0]
	var action_btn_ind : int = used_inputs[key][1]
	
	_erease_action(action_to_erease,action_btn_ind,current_event.action_event)
	
	_safe_rebind()

func _erease_action(action_name: String, ind: int, event: InputEvent) -> void:
	var btn : RebindBtn = container.get_node(action_name)
	
	# Erease from input map
	InputMap.action_erase_event(action_name,event)
	# Erease from used_inputs
	used_inputs.erase(_format_event(event))
	# Erease from btn 
	btn.set_input(ind,null)

func _format_event(event: InputEvent) -> String:
	if event == null:
		return ""
	return event.as_text().trim_suffix(" - Physical")
