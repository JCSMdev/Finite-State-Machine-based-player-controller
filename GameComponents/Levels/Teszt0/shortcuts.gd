extends VBoxContainer



# Track what we are currently remapping
var active_button: Button = null
var active_action: String = ""
var active_index: int = 0 # 0 for Primary, 1 for Secondary


func _ready() -> void:
	for action in InputMap.get_actions().filter(func(e: String): return not e.begins_with("ui")):
		var cont := HBoxContainer.new()
		cont.name = action
		cont.alignment = BoxContainer.ALIGNMENT_CENTER
		# 1. Action Label
		var label := Label.new()
		label.text = action.capitalize()
		label.custom_minimum_size.x = 150
		cont.add_child(label)
		
		# Get currently bound events (up to 2)
		var events = InputMap.action_get_events(action)
		
		# 2. Primary Button (Index 0)
		var btn_primary := Button.new()
		btn_primary.custom_minimum_size.x = 180
		var primary_event = events[0] if events.size() > 0 else null
		btn_primary.text = _get_event_text(primary_event)
		btn_primary.pressed.connect(func(): _start_remapping(action, btn_primary, 0))
		cont.add_child(btn_primary)
		
		# 3. Secondary Button (Index 1)
		var btn_secondary := Button.new()
		btn_secondary.custom_minimum_size.x = 180
		var secondary_event = events[1] if events.size() > 1 else null
		btn_secondary.text = _get_event_text(secondary_event)
		btn_secondary.pressed.connect(func(): _start_remapping(action, btn_secondary, 1))
		cont.add_child(btn_secondary)
		
		add_child(cont)



func _start_remapping(action: String, button: Button, index: int) -> void:
	if active_button != null:
		return # Already waiting for a key elsewhere
		
	active_button = button
	active_action = action
	active_index = index
	active_button.text = "... Press Key/Mouse ..."


func _unhandled_input(event: InputEvent) -> void:
	if active_button == null:
		return
		
	# Check if it's a valid press event (Keyboard, Mouse Click, or Mouse Wheel)
	var is_valid_press = false
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		is_valid_press = true
		
	if is_valid_press:
		# Stop the event from bubbling up and triggering game actions immediately
		get_viewport().set_input_as_handled()
		
		# Update the InputMap safely for Primary vs Secondary slots
		_update_input_map(active_action, event, active_index)
		
		# Update button text and clear lock states
		active_button.text = _get_event_text(event)
		active_button = null
		active_action = ""


func _update_input_map(action: String, new_event: InputEvent, slot_index: int) -> void:
	var events = InputMap.action_get_events(action)
	
	# Clean up matches: If they mapped 'W' to secondary, but 'W' was already primary,
	# we should clear it out so a single key isn't assigned twice to the same action.
	for i in range(events.size()):
		if events[i].as_text() == new_event.as_text():
			InputMap.action_erase_event(action, events[i])
	
	# Fetch updated list after duplicate cleanup
	events = InputMap.action_get_events(action)
	
	# Reconstruct the list prioritizing our slot change
	InputMap.action_erase_events(action)
	
	if slot_index == 0:
		# Replacing primary slot
		InputMap.action_add_event(action, new_event)
		if events.size() > 1: # Keep the old secondary if it existed
			InputMap.action_add_event(action, events[1])
	elif slot_index == 1:
		# Replacing secondary slot
		if events.size() > 0: # Keep the old primary
			InputMap.add_action(action) # Safeguard initialization
			InputMap.action_add_event(action, events[0])
		InputMap.action_add_event(action, new_event)


# Helper function to turn InputEvents into human-readable text strings
func _get_event_text(event: InputEvent) -> String:
	if event == null:
		return "Unbound"
		
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT: return "Left Mouse"
			MOUSE_BUTTON_RIGHT: return "Right Mouse"
			MOUSE_BUTTON_MIDDLE: return "Middle Mouse"
			MOUSE_BUTTON_WHEEL_UP: return "Wheel Up"
			MOUSE_BUTTON_WHEEL_DOWN: return "Wheel Down"
			_: return "Mouse Button " + str(event.button_index)
			
	return event.as_text().trim_suffix("- Physical")
