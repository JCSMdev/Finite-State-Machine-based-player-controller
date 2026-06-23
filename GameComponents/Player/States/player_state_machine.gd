class_name PlayerStateMachine extends StateMachine

@export var player : Player

func _ready() -> void:
	populate(self)
	print(states.keys())

func _unhandled_input(event: InputEvent) -> void:
	current_state.unhandled_input(event)

func populate(node: Node) -> void:
	for child in node.get_children():
		if child is PlayerState:
			child.state_machine = self
			child.player = player
			states[child.name.to_lower()] = child
		else:
			populate(child)
	if initial_state:
		initial_state.enter()
		current_state = initial_state
		
	
