extends RefCounted
class_name JoyTypeEvent

## An event emitted by [JoyTypeListener] that contains JoyType information.

var content = ""
var is_text : bool = true

## Creates a new [JoyTypeEvent] with an associated text.
static func text(text : String) -> JoyTypeEvent:
	var jt = JoyTypeEvent.new()
	jt.content = text
	return jt

## Creates a new [JoyTypeEvent] that encodes a special operation.
static func special(operation : StringName) -> JoyTypeEvent:
	var jt = JoyTypeEvent.new()
	jt.content = operation
	jt.is_text = false
	return jt

## A string representation of this event
func _to_string():
	return "[JoyTypeEvent %s]" % content
