extends Node
class_name JoyTypeWriter

## A class that writes joypad events it receives
## to a target control that supports text.
##
## Extend this class to customize its behaviour to different controls.
## This class receives JoyType events from [JoyTypeListener].

func _event_received(ev : JoyTypeEvent):
	pass
