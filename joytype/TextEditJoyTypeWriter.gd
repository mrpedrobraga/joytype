extends JoyTypeWriter

## Implementation of [JoyTypeWriter] that types on a text edit.
var _te : TextEdit

func _notification(what):
	if what == NOTIFICATION_PARENTED:
		update_te()
func _ready():
	update_te()
func update_te():
	if get_parent() is TextEdit:
		_te = get_parent()
	else:
		_te = null

func _get_configuration_warnings():
	if _te is TextEdit:
		return []
	return ["Parent must be a Text Edit."]

func _event_received(ev : JoyTypeEvent):
	if not _te: return
	
	_te.grab_focus()
	if ev.is_text:
		_te.insert_text_at_caret(ev.content)
	else:
		match ev.content:
			&"BACKSPACE":
				_te.backspace()
			&"DELETE":
				for i in _te.get_caret_count():
					_te.set_caret_column(_te.get_caret_column(i)+1, true, i)
				_te.backspace()
			&"LEFT":
				for i in _te.get_caret_count():
					_te.set_caret_column(_te.get_caret_column(i)-1, true, i)
			&"UP":
				for i in _te.get_caret_count():
					_te.set_caret_line(_te.get_caret_line(i)-1, true, i)
			&"RIGHT":
				for i in _te.get_caret_count():
					_te.set_caret_column(_te.get_caret_column(i)+1, true, i)
			&"DOWN":
				for i in _te.get_caret_count():
					_te.set_caret_line(_te.get_caret_line(i)+1, true, i)
