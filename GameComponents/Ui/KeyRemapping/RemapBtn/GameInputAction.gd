extends Resource
class_name GameInputAction

var action_name : String = ""
var action_ind : int = 0
var action_event : InputEvent = null

func init(name: String,ind: int,event: InputEvent) -> GameInputAction:
	action_name = name
	action_ind = ind
	action_event = event
	return self
	
