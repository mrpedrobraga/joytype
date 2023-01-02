extends Node
class_name JoyTypeListener

## A class that allows you to type with a joypad (a game controller).
##
## It listens to joypad events and broadcasts them so a [JoyTypeWriter]
## can handle them in its own way -- like, for example, editing a [TextEdit]
## or some [String] property.
## [br][br]
## The current implementation works like this:[br][br]
##
## [b]R[/b] (the right analog stick) lets you input letters,
## depending on which direction you push it (UP, DOWN, LEFT, RIGHT).
## [br]
## [b]L[/b]'s direction dictates which cluster of four letters [b]R[/b]
## will have access to.[br]
## Therefore, combinations of [b]L[/b] and [b]R[/b] give you access
## to 16 different entries.[br][br]
##
## Since that's obviously less than 26, you can press a modifier key
## to turn the joypad to its 'BACK.' [br]
## In the '[member using_backside]' mode, you have access to 16 more entries.[br][br]
## That's 32

@export_category("JoyType")

## Whether this listener is can register and emit events.
@export var active = false

## The ID of the joypad device this node is listening to.
@export var device = 0

## If this node is currently using the backside.
##
## The backside gives you access to 
var using_backside : bool = false

@export_group("Input Mapping")
## The button used to trigger the backside (LS by default).
##
## You'll have to create an action on the Input Map to trigger this.
@export var backside_modifier_button := JOY_BUTTON_LEFT_SHOULDER
## Whether the backside modifier works by toggling it on-and-off instead of
## holding.
@export var backside_toggles := false

## The button to trigger a delete action (backspace or delete) (RS by default).
##
## You'll have to create an action on the Input Map to trigger this.
@export var backspace_button := JOY_BUTTON_RIGHT_SHOULDER

@export var action_R_LEFT  : StringName = &"R_LEFT"
@export var action_R_UP    : StringName = &"R_UP"
@export var action_R_DOWN  : StringName = &"R_DOWN"
@export var action_R_RIGHT : StringName = &"R_RIGHT"

@export_group("Extra Settings")
## How far a joystick has to travel in an axis before it counts.
## NOT IN USE.
var _deadzone : float = 0.5

signal event_emitted(event)

## Emits a [JoyTypeEvent].
func emit(event : JoyTypeEvent):
	event_emitted.emit(event)

# Quick functions for convenience ;)
func _etext(t : String): emit(JoyTypeEvent.text(t))
func _especial(op : StringName): emit(JoyTypeEvent.special(op))

enum {
	LEFT, UP, RIGHT, DOWN, NONE = -1
}

# Handling input for non-analog stick related events
func _input(event):
	if not active:
		return
	if not event.device == device:
		return
	
	if event is InputEventJoypadButton:
		# Switch between the front and backside
		# default behaviour is hold_to_switch.
		if event.button_index == backside_modifier_button:
			if backside_toggles:
				if event.is_action_pressed():
					using_backside != using_backside
			else:
				using_backside = event.is_pressed()
			return
		
		if event.is_pressed():
			# Emit Backspace!!!
			if event.button_index == backspace_button:
				_especial(&"BACKSPACE" if not using_backside else &"DELETE")
				return

func _physics_process(_delta):
		var key_cluster = NONE
		var key = NONE
		
		var R := Vector2(
			Input.get_axis(action_R_LEFT, action_R_RIGHT),
			Input.get_axis(action_R_UP, action_R_DOWN)
		)
		
		var L := Vector2(
			Input.get_joy_axis(device, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
		)
		
		var R_any_just_pressed := false
		for i in [action_R_LEFT, action_R_UP, action_R_DOWN, action_R_RIGHT]:
			R_any_just_pressed = R_any_just_pressed or\
				Input.is_action_just_pressed(i)
		
		# If just pressed any of the R directions
		if R_any_just_pressed:
			
			
			if L.length_squared() > 0.5:
				if abs(L.x) > abs(L.y):
					if L.x == -1:
						key_cluster = LEFT
					if L.x ==  1:
						key_cluster = RIGHT
				else:
					if L.y == -1:
						key_cluster = UP
					if L.y ==  1:
						key_cluster = DOWN
			
			
			if Input.is_action_just_pressed("R_LEFT"):
				key = LEFT
			if Input.is_action_just_pressed("R_RIGHT"):
				key = RIGHT
			if Input.is_action_just_pressed("R_UP"):
				key = UP
			if Input.is_action_just_pressed("R_DOWN"):
				key = DOWN
			
			if key == NONE:
				print(R)
				return
			
			if key_cluster == NONE:
				_especial(
					{
						LEFT: &"LEFT",
						UP:   &"UP",
						RIGHT:&"RIGHT",
						DOWN: &"DOWN"
					}[key]
				)
				return
			_etext(keys[using_backside][key_cluster][key])

var keys = {
	# Frontside of normal characters
	false: {
		LEFT: {
			LEFT: "A",
			UP: "E",
			RIGHT: "O",
			DOWN: "U"
		},
		UP: {
			LEFT: "D",
			UP: "B",
			RIGHT: "G",
			DOWN: "W"
		},
		RIGHT: {
			LEFT: "J",
			UP: "K",
			RIGHT: "T",
			DOWN: "X"
		},
		DOWN: {
			LEFT: "F",
			UP: "V",
			RIGHT: ",",
			DOWN: " "
		}
	},
	
	# Backside of normal characters
	true: {
		LEFT: {
			LEFT: "C",
			UP: "S",
			RIGHT: "Z",
			DOWN: "H"
		},
		UP: {
			LEFT: "M",
			UP: "N",
			RIGHT: "P",
			DOWN: "Q"
		},
		RIGHT: {
			LEFT: "I",
			UP: "Y",
			RIGHT: "L",
			DOWN: "R"
		},
		DOWN: {
			LEFT: "\t",
			UP: "?",
			RIGHT: ".",
			DOWN: "\n"
		}
	}
}
