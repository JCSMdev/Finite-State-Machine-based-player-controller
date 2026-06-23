extends State
class_name PlayerState

var player : Player

signal on_enter(name:String)
signal on_exit(name:String)

func unhandled_input(event: InputEvent) -> void:
	pass
func enter() -> void:
	on_enter.emit(name)

func handle_jump() -> void:
	if player.timers["jump_buffer"].time_left > 0: # van aktív jump
		if test_climb():
			state_machine.change_state("climbing")
		elif test_jump():
			state_machine.change_state("jumping")

func test_climb() -> bool:
	if player.raycasts.is_colliding():
		if state_machine.current_state.name != "Climbing":
			return true
	return false

func test_jump() -> bool:
	if player.timers["jump_cooldown"].time_left == 0:
		if player.is_on_floor() or player.timers["coyote"].time_left > 0:
			return true
	return false

func exit() -> void:
	on_exit.emit(name)
